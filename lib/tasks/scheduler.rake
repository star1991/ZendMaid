desc "This task is emails all customers to remind them of upcoming appointments"
task :email_appointment_reminders => :environment do

  User.where(:active => true).each do |user|
    reminder_template = user.email_templates.find_by_template_type("Appointment Reminder")
    if reminder_template.blank? || reminder_template.time_offset == nil
      next
    end

    title_template = Liquid::Template.parse(reminder_template.title)
    body_template = Liquid::Template.parse(reminder_template.body)

    target_date = DateTime.now - reminder_template.time_offset.seconds
    upcoming_appointments = user.appointments.actual.where( :start_time => (target_date.beginning_of_day..target_date.end_of_day) ).where(:status_id => reminder_template.preferences[:after_status])
    upcoming_appointments.each do |appointment|
      if appointment.sent_on["Appointment Reminder Email"].blank? && (appointment.customer.automatable_emails.size > 0)
        AppointmentsMailer.email_template(appointment, appointment.customer.automatable_emails.map(&:address), title_template, body_template).deliver
        appointment.sent_on["Appointment Reminder Email"] = Time.zone.now
        appointment.allow_conflicts = true
        appointment.save
      end
    end
  end
end

task :text_appointment_reminders => :environment do
  client = Twilio::REST::Client.new(Rails.configuration.twilio[:account_sid], Rails.configuration.twilio[:auth_token])

  User.where(:active => true).each do |user|
    reminder_template = user.text_templates.find_by_template_type("Appointment Reminder")
    if reminder_template.blank? || reminder_template.time_offset == nil
      next
    end
    body_template = Liquid::Template.parse(reminder_template.body)

    target_date = DateTime.now - reminder_template.time_offset.seconds
    upcoming_appointments = user.appointments.actual.where(:start_time => (target_date.beginning_of_day..target_date.end_of_day) ).where(:status_id => reminder_template.preferences[:after_status])
    upcoming_appointments.each do |appointment|
      phone_number = appointment.customer.phone_numbers.find_by_phone_number_type("Cell")
      if appointment.sent_on["Appointment Reminder Text"].blank? && phone_number.present?
        # Save appointment anyways so that reminder doesn't go out at wrong time
        appointment.allow_conflicts = true
        appointment.sent_on["Appointment Reminder Text"] = Time.zone.now
        appointment.save
        begin
          appointment_drop = AppointmentDrop.new(appointment)
          client.account.messages.create(:from => Rails.configuration.twilio[:from], :to => phone_number.phone_number, :body => body_template.render('appointment' => appointment_drop))
        rescue Twilio::REST::RequestError => e
          Rails.logger.info "Twilio Request Error #{e.message}"
        end

      end
    end
  end
end

desc "This task emails a daily digest of appointments to each user"
task :email_appointments_digest => :environment do

  User.where(:active => true).each do |user|
    work_order_template = user.email_templates.find_by_template_type("Work Order")
    if user.send_daily_digest == true && work_order_template.present?
      appointments = user.appointments.actual.joins(:status).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time between ? AND  ?", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day).order("appointments.start_time ASC")
      body_template = Liquid::Template.parse(work_order_template.body)
      AppointmentsMailer.work_order_digest(user.email, "no-reply@zenmaid.com", "[ZenMaid] Schedule for #{Time.zone.now.strftime('%-m/%-d/%Y')}", appointments, body_template).deliver
    end
  end
end


desc "This task emails a digest of the daily appointments to each employee"
task :email_employee_work_order_digest => :environment do
  User.where(:active => true).each do |user|
    work_order_template = user.email_templates.find_by_template_type("Work Order")
    if work_order_template.present? && work_order_template.time_offset != nil
      body_template = Liquid::Template.parse(work_order_template.body)

      employees_with_appointments = user.employees.includes({:assigned_appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time between ? AND  ?", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day).order("appointments.start_time ASC")
      employees_with_appointments.each do |employee|
        if employee.email.present?
          AppointmentsMailer.work_order_digest(employee.email, user.user_profile.try(:company_email), "#{employee.user.user_profile.try(:company_name)}] Schedule for #{Time.zone.now.strftime('%-m/%-d/%Y')}", employee.assigned_appointments, body_template).deliver

          employee.assigned_appointments.each do |appointment|
            appointment.sent_on["Work Order Email"] = Time.zone.now
            appointment.allow_conflicts = true
            appointment.save
          end

        end
      end
    end
  end
end



desc "This task texts a digest of the daily appointments to each employee"
task :text_employee_work_order_digest => :environment do
  client = Twilio::REST::Client.new(Rails.configuration.twilio[:account_sid], Rails.configuration.twilio[:auth_token])

  User.where(:active => true).each do |user|
    work_order_template = user.text_templates.find_by_template_type("Work Order")
    next if work_order_template.blank? || work_order_template.time_offset.nil?
    
    body_template = Liquid::Template.parse(work_order_template.body)

    employees_with_appointments = user.employees.includes({:assigned_appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time between ? AND ?", (Time.zone.now + 1.days).beginning_of_day, (Time.zone.now + 1.days).end_of_day).order("appointments.start_time ASC")
    employees_with_appointments.each do |employee|

      if employee.phone_number.present?
        employee.assigned_appointments.each do |appointment|
          begin
            appointment_drop = AppointmentDrop.new(appointment)
            client.account.messages.create(:from => Rails.configuration.twilio[:from], :to => employee.phone_number, :body => body_template.render('appointment' => appointment_drop))

            appointment.sent_on["Work Order Text"] = Time.zone.now
            appointment.allow_conflicts = true
            appointment.save
          rescue Twilio::REST::RequestError => e
            next
          end
        end

      end
    end
  end
end

desc "This task sends follow-up emails for appointments"
task :email_appointments_follow_up => :environment do
  User.where(:active => true).each do |user|
    follow_up_template = user.email_templates.find_by_template_type("Appointment Follow-Up")

    if follow_up_template.present? && follow_up_template.time_offset != nil

      target_date = DateTime.now - follow_up_template.time_offset.seconds
      upcoming_appointments = user.appointments.actual.where( :start_time => (target_date.beginning_of_day..target_date.end_of_day) )

      title_template = Liquid::Template.parse(follow_up_template.title)
      body_template = Liquid::Template.parse(follow_up_template.body)

      upcoming_appointments.each do |appointment|
        if appointment.sent_on["Appointment Follow-Up Email"].blank? && (appointment.customer.automatable_emails.size > 0)

          if follow_up_template.send_follow_up?(appointment, appointment.customer)
            AppointmentsMailer.email_template(appointment, appointment.customer.automatable_emails.map(&:address), title_template, body_template).deliver
            appointment.sent_on["Appointment Follow-Up Email"] = Time.zone.now
            appointment.allow_conflicts = true
            appointment.save
          end

        end
      end

    end
  end
end


desc "This task sends come back emails to customers who haven't booked appointments in a while"
task :email_come_back => :environment do
  User.where(:active => true).each do |user|
    # Only run this script on Sunday
    if Time.zone.now.sunday?
   
      come_back_template = user.email_templates.find_by_template_type("Come Back")
    
      if come_back_template.present? && come_back_template.time_offset != nil
        title_template = Liquid::Template.parse(come_back_template.title)
        body_template = Liquid::Template.parse(come_back_template.body)
      
        recent_customer_ids = user.customers.joins(:appointments).where("appointments.use_as_prototype = ?", false).where("appointments.start_time > ?", Time.zone.now - come_back_template.time_offset.weeks).pluck(:id).uniq
        old_customers = user.customers.joins(:appointments).where("customers.id not in (?)", recent_customer_ids).readonly(false).group("customers.id HAVING count(appointments.id) > 0")
      
        old_customers.each do |customer|
          if customer.sent_on["Come Back Email"].blank? && customer.automatable_emails.size > 0
            customer_drop = CustomerDrop.new(customer)  
            AppointmentsMailer.email_generated(customer.automatable_emails.map(&:address), user.user_profile.try(:company_email), title_template.render('customer' => customer_drop), body_template.render('customer' => customer_drop)).deliver
        
            customer.sent_on["Come Back Email"] = Time.zone.now
            customer.save
          end
        end
      end
   
    end
  end
  
end


desc "This extends repeating appointments in the system a maximum of 6 months"
task :prepopulate_appointments => :environment do
  
  if Time.zone.now.saturday?
    
    Subscription.where("subscriptions.frequency > ?", 0).where(:active => true).find_each do |s|
    
      # prepopulate_appointments automatically inactivates the subscription after it populates the repeat_until marker
      # only returns nil if prototype is not present or subscription has already been prepopulated past prototype
      # Default prepopulation is 6 months into the future -- AD 2/23/14
      materialized_until = s.prepopulate_appointments
    
      # This saves the updates to the subscription record and all newly made appointments
      s.save!
    
      # move date and time of prototype to materialized_until to avoid unnecessary calculation in the future
      if materialized_until.present?
        p = s.appointment_prototype
        appointment_length = p.end_time - p.start_time
        p.start_time = materialized_until
        p.end_time = materialized_until + appointment_length
      
        p.save!
      end
   
   end 
  end
end

desc "This task extendes repeating tasks in the system by the default amount (2 months)"
task :prepopulate_tasks => :environment do 
  if Time.zone.now.friday?    
    TaskRecurrence.find_each do |t|
      t.populate_tasks
    end 
  end
end

desc "This task will update customer balances"
task :update_customer_balances => :environment do
  Customer.find_each do |customer|
    customer.balance = 0
    customer.revenue = 0
    
    customer.appointments.actual.joins(:status).where("statuses.use_for_invoice = ?", true).where("appointments.start_time < ?", Time.zone.now.end_of_day).each do |appointment|
      if appointment.price.present?
        if !appointment.paid?
          customer.balance += appointment.price
        end

        customer.revenue += appointment.price
      end
    end

    customer.save
  end

end

desc "This task will set users who's free trials have expired to inactive"
task :set_free_trial_to_expire => :environment do
  User.where("plan_id is NULL and active is TRUE").where("free_trial_end < ?", Time.zone.now.beginning_of_day).update_all(:active => false)
end

desc "This task renews quickbooks access tokens for customers whose tokens are about to expire"
task :renew_qb_access_token => :environment do
  User.where("qb_company_id is not NULL").where(:active => true).where("qb_reconnect_token_at < ?", Time.zone.now).each do |user|
    access_token = OAuth::AccessToken.new($qb_oauth_consumer, user.qb_access_token, user.qb_access_secret)

    service = Quickbooks::Service::AccessToken.new
    service.access_token = access_token
    service.company_id = user.qb_company_id
    result = service.renew

    # result is an AccessTokenResponse, which has fields +token+ and +secret+
    # update your local record with these new params
    if result.token.present?
      user.qb_access_token = result.token
      user.qb_access_secret = result.secret
      user.qb_token_expires_at = 6.months.from_now
      user.qb_reconnect_token_at = 5.months.from_now
      user.save
    else
      user.qb_access_token = nil
      user.qb_access_secret = nil
      user.qb_company_id = nil

      user.qb_token_expires_at = nil
      user.qb_reconnect_token_at = nil
      user.save
    end
    
  end
end

