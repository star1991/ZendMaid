QuickbooksSyncJob = Struct.new(:user, :employee, :request) do
  def perform 
    case request
    when 'from_quickbook'
      import_from_qb
      AppointmentsMailer.from_quickbooks_finished_syncing(employee.email).deliver
    when 'to_quickbook'
      export_to_qb
      AppointmentsMailer.to_quickbooks_finished_syncing(employee.email).deliver
    when 'both_way'
      import_from_qb
      export_to_qb
      AppointmentsMailer.quickbooks_both_finished_syncing(employee.email).deliver
    end    

    user.reload
    user.qb_last_sync = Time.zone.now
    user.qb_syncing = false
    user.save  
  end

  def import_from_qb

    access_token = OAuth::AccessToken.new($qb_oauth_consumer, user.qb_access_token, user.qb_access_secret)

    service = Quickbooks::Service::Customer.new
    service.company_id = user.qb_company_id
    service.access_token = access_token

    existing_qb_customers = Set.new(user.customers.pluck(:qb_customer_id))

    service.query_in_batches(nil, per_page: 200) do |batch|
      batch.each do |qb_customer|
         # Don't recreate customer if already synced
        if existing_qb_customers.include?(qb_customer.id.to_i)
         next
        end

       c = user.customers.build
       # Build all custom fields
       user.customer_fields.each do |customer_field|
         c.customer_items.build(:custom_field_id => customer_field.id, :value_name => customer_field.default)
       end
       c.qb_customer_id = qb_customer.id

       c.notes = qb_customer.notes
       c.title = qb_customer.title
       c.first_name = qb_customer.given_name
       c.last_name = qb_customer.family_name
       c.company_name = qb_customer.company_name
       c.balance = qb_customer.balance

       c.lead = false
       c.allow_duplicate = true

        if c.save
          if qb_customer.mobile_phone.present?
           p = c.phone_numbers.build(:phone_number => qb_customer.mobile_phone.free_form_number, :phone_number_type => "Cell")
            p.save
          end

          if qb_customer.primary_phone.present?
            p = c.phone_numbers.build(:phone_number => qb_customer.primary_phone.free_form_number, :phone_number_type => "Home")
            p.save
          end

          if qb_customer.alternate_phone.present?
           p = c.phone_numbers.build(:phone_number => qb_customer.alternate_phone.free_form_number, :phone_number_type => "Other")
           p.save
          end            

          if qb_customer.fax_phone.present?
            p = c.phone_numbers.build(:phone_number => qb_customer.fax_phone.free_form_number, :phone_number_type => "Fax")
            p.save
          end
                
          if qb_customer.primary_email_address.present?
            e = c.emails.build(:address => qb_customer.primary_email_address.address)
            e.save
          end

          if qb_customer.shipping_address.present?
            a = c.addresses.build(:line1 => qb_customer.shipping_address.line1, :line2 => qb_customer.shipping_address.line2, :city => qb_customer.shipping_address.city, :state => qb_customer.shipping_address.country_sub_division_code, :postal_code => qb_customer.shipping_address.postal_code)
            a.save
          end

          if qb_customer.billing_address.present?
            a = c.addresses.build(:line1 => qb_customer.billing_address.line1, :line2 => qb_customer.billing_address.line2, :city => qb_customer.billing_address.city, :state => qb_customer.billing_address.country_sub_division_code, :postal_code => qb_customer.billing_address.postal_code, :billing => true)
            a.save
         end  
       end
      end
    end

    # reload user so that unsaved customers do not prevent user from being saved
    #  TODO: Include list of quickbooks ID's for unsaved customers in email

  end

  def export_to_qb

    access_token = OAuth::AccessToken.new($qb_oauth_consumer, user.qb_access_token, user.qb_access_secret)
    service = Quickbooks::Service::Customer.new
    service.company_id = user.qb_company_id
    service.access_token = access_token

    #puts local_customers.map(&:id)
    user.customers.where("qb_customer_id IS NULL").find_in_batches(:batch_size => 25) do |local_customers|

      local_customers.each do |local_customer|

        begin
          customer = Quickbooks::Model::Customer.new
          customer.notes = local_customer.notes
          customer.title = local_customer.title
          customer.given_name = local_customer.first_name
          customer.family_name = local_customer.last_name
          customer.company_name = local_customer.company_name
      
          if local_customer.emails.present?
            customer.email_address = local_customer.emails.last.address
          end

          # assign cell phone number
          cell_phone = local_customer.phone_numbers.where(:phone_number_type => "Cell").last
          unless cell_phone.blank?
            phone1 = Quickbooks::Model::TelephoneNumber.new
            phone1.free_form_number = cell_phone.phone_number
            customer.mobile_phone = phone1
          end

          # assign home phone number
          home_phone = local_customer.phone_numbers.where(:phone_number_type => "Home").last
          unless  home_phone.blank?
            phone2 = Quickbooks::Model::TelephoneNumber.new
            phone2.free_form_number =home_phone.phone_number
            customer.primary_phone = phone2
          end

            # assign other phone number
          other_phone = local_customer.phone_numbers.where(:phone_number_type => "Other").last
          unless other_phone.blank?
            phone3 = Quickbooks::Model::TelephoneNumber.new
            phone3.free_form_number = other_phone.phone_number
            customer.alternate_phone = phone3
          end
              
          # assign fax phone number
          fax_phone = local_customer.phone_numbers.where(:phone_number_type => "Fax").last
          unless fax_phone.blank?
            phone4 = Quickbooks::Model::TelephoneNumber.new
            phone4.free_form_number =fax_phone.phone_number
            customer.fax_phone = phone4
          end  
                  
          if billing_address = local_customer.billing_address
            qb_billing_address = Quickbooks::Model::PhysicalAddress.new
            qb_billing_address.line1 = billing_address.line1
            qb_billing_address.line2 = billing_address.line2
            qb_billing_address.city = billing_address.city
            qb_billing_address.country_sub_division_code= billing_address.state
            qb_billing_address.postal_code = billing_address.postal_code
            customer.billing_address = qb_billing_address
          end             
            
          if shipping_address = local_customer.addresses.where(:billing => false).last
            qb_shipping_address = Quickbooks::Model::PhysicalAddress.new
            qb_shipping_address.line1 = shipping_address.line1
            qb_shipping_address.line2 = shipping_address.line2
            qb_shipping_address.city = shipping_address.city
            qb_shipping_address.country_sub_division_code = shipping_address.state
            qb_shipping_address.postal_code = shipping_address.postal_code
            customer.shipping_address =  qb_shipping_address
          end
          
          c = service.create(customer)
          local_customer.qb_customer_id = c.id
          local_customer.save
        rescue
          next
        end

      end
    end
  end
  
  def error(job, exception)
    # set qb_syncing to false so user can restart sync upon failure
    user.reload
    user.qb_syncing = false
    user.save
  end
end 
