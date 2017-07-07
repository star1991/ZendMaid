# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  active             :boolean          default(TRUE)
#  company_name       :string(255)
#  title              :string(255)
#  sent_on            :text
#  notes              :text
#  balance            :decimal(10, 2)   default(0.0)
#  revenue            :decimal(10, 2)   default(0.0)
#  stripe_customer_id :string(255)
#  lead               :boolean          default(TRUE)
#  qb_customer_id     :integer
#  imported           :boolean          default(FALSE)
#  marketing_source   :string(255)
#


class Customer < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :email, :first_name, :last_name, :phone_number, :company_name, :title, :user_id, :notes, :subscriptions_attributes, :addresses_attributes, :from_instant_booking, :active, 
    :customer_items_attributes, :allow_duplicate, :phone_numbers_attributes, :emails_attributes, :notes, :credit_cards_attributes, 
    :lead,:imported , :marketing_source, :new_marketing_source

  attr_accessor :from_instant_booking, :allow_duplicate, :billing_address, :new_marketing_source
  
  serialize :sent_on, Hash
  
  belongs_to :user
  has_many :addresses, :as => :addressable, :dependent => :destroy, :autosave => true
  
  has_many :service_addresses, :as => :addressable, :class_name => "Address", :conditions => {:billing => false}
  
  has_many :subscriptions, :as => :subscriptionable, :dependent => :destroy
  has_many :appointments, :through => :subscriptions
  
  has_many :phone_numbers, :as => :phone_numberable, :dependent => :destroy
  
  has_many :emails, :as => :emailable, :dependent => :destroy
  has_many :automatable_emails, :as => :emailable, :class_name => "Email", :conditions => {:send_automated => true}
  
  has_many :attached_notes, :as => :noteable, :class_name => "AttachedNote", :dependent => :destroy
  
  has_many :log_entries, :through => :appointments
  
  has_many :customer_items, :as => :customizable, :class_name => "CustomItem", :dependent => :destroy
  
  has_many :credit_cards, :dependent => :destroy

  accepts_nested_attributes_for :subscriptions
  accepts_nested_attributes_for :addresses, :reject_if => Proc.new { |a| a[:line1].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :customer_items, :allow_destroy => true
  accepts_nested_attributes_for :credit_cards
  accepts_nested_attributes_for :phone_numbers, :reject_if => Proc.new { |ph| ph[:phone_number].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :emails, :reject_if => Proc.new { |e| e[:address].blank? }, :allow_destroy => true

  
  before_validation do |customer|
    customer.company_name = company_name.present? ? company_name.split.map(&:capitalize).join(' ') : nil
    customer.first_name = nil if customer.first_name.blank?
    customer.last_name = nil if customer.last_name.blank?

  end
  
  validates :user_id, :presence => true
  validate :name_present
  validate :check_for_duplicates, :if => Proc.new { |c| c.new_record? && !string_to_boolean(c.allow_duplicate) }
  
  scope :active, where(:active => true)
  scope :imported, where(:imported => true)
  scope :created_between, lambda{ |starttime, endtime| where("created_at BETWEEN ? AND ?", starttime, endtime) }
  
  def get_possible_duplicates
    self.user.customers.includes(:addresses, :phone_numbers, :emails).where("(lower(first_name) = ? AND lower(last_name) = ?) OR lower(company_name) = ? OR emails.address IN (?) OR phone_numbers.phone_number IN (?) OR lower(addresses.line1) IN (?)", 
        self.first_name.try(:downcase), 
        self.last_name.try(:downcase), 
        self.company_name.try(:downcase), 
        self.emails.map { |email| email.address }, 
        self.phone_numbers.map { |ph| ph.phone_number }, 
        self.addresses.map { |address| address.line1.try(:downcase) })
  end
  
  def check_for_duplicates
    
    if self.name_present
      possible_duplicates = self.get_possible_duplicates

      if possible_duplicates.present?
        errors.add(:base, possible_duplicates.map(&:id))
      end
    end
  end
  
  def name_present
    if not (self.first_name.present? or self.last_name.present? or self.company_name.present?)
      errors.add(:first_name, '')
      errors.add(:last_name, '')
      errors.add(:company_name, 'First name, last name, or company name must be present')
      return false
    else
      return true
    end
  end
  
  def billing_address
    @billing_address ||= self.addresses.where(:billing => true).try(:first)
  end
  
  def contact_name
    [title, first_name, last_name].join(' ').strip
  end
  
  def full_name
    contact_name = self.contact_name
    if contact_name.present?
      if company_name.present?
        "#{contact_name} (#{company_name})"
      else
        contact_name
      end
    else
      company_name
    end
  end
  
  def initialize_from_booking(instant_booking)
    if instant_booking.present?
      self.first_name = instant_booking.first_name
      self.last_name = instant_booking.last_name
      self.phone_numbers.build(:phone_number_type => "Home", :phone_number => instant_booking.phone_number)
      self.emails.build(:address => instant_booking.email)
      
      booking_address = instant_booking.address
      self.addresses << Address.new(:line1 => booking_address.line1, :state => booking_address.state, :postal_code => booking_address.postal_code, :city => booking_address.city)
      self.addresses << Address.new(:line1 => booking_address.line1, :state => booking_address.state, :postal_code => booking_address.postal_code, :city => booking_address.city, :billing => true)
    end
  end
  
  def self.get_import_file_local_copy(remote_url)
    # We create a local copy of remote resource
    local_resource = LocalResource.local_resource_from_url(remote_url)

    # We have a copy of the remote file for processing
    local_resource.file
  end

  def self.import(file_id, user_id, params={})
    begin
      import_file = ImportRequestFile.find(file_id)

      import_file_local_copy = get_import_file_local_copy(import_file.file.to_s)

      errors = []
      current_user = User.find_by_id(user_id)

      num_saved, num_error, failed_customers = 0, 0, []  
      
      is_active = params[:inactive] == '1' ? false : true
      al_dup = params[:filter_duplicate] == '1' ? false : true
      row_num = 0
      CSV.foreach(import_file_local_copy.path, :headers => true,  :encoding => 'ISO-8859-1') do |row|
        row_num += 1
        row_data = {}
        row.to_hash.each_pair do |k, v|
          if not k.nil?
            row_data[k.downcase.strip.delete(' ')] = v
          end
        end
        
        customer = current_user.customers.build(:first_name => row_data["firstname"], :last_name => row_data["lastname"], :company_name => row_data["companyname"], :active => is_active, :allow_duplicate => al_dup)

        if row_data["cellphonenumber"].present?
          customer.phone_numbers.build(:phone_number => row_data["cellphonenumber"], :phone_number_type => "Cell")
        end

        if row_data["homephonenumber"].present?
          customer.phone_numbers.build(:phone_number => row_data["homephonenumber"], :phone_number_type => "Home")
        end

        if row_data["workphonenumber"].present?
          customer.phone_numbers.build(:phone_number => row_data["workphonenumber"], :phone_number_type => "Work")
        end

        if row_data["spousephonenumber"].present?
          customer.phone_numbers.build(:phone_number => row_data["spousephonenumber"], :phone_number_type => "Spouse")
        end

        if row_data["otherphonenumber"].present?
          customer.phone_numbers.build(:phone_number => row_data["otherphonenumber"], :phone_number_type => "Other")
        end

        if row_data["faxphonenumber"].present?
          customer.phone_numbers.build(:phone_number => row_data["faxphonenumber"], :phone_number_type => "Fax")
        end
          
        if row_data["email"].present?
          customer.emails.build(:address => row_data["email"])
        end
        
        if row_data["notes"].present?
          customer.attached_notes.build(:body => row_data["notes"])
        end         
        
        current_user.customer_fields.each do |field|
          item = customer.customer_items.build(:custom_field_id => field.id)
          item.value_name = row_data[field.field_name.downcase.strip.delete(' ')] 
        end
        
        if row_data["addressline1"].present?
          customer.addresses.build(:line1 => row_data["addressline1"], :line2 => row_data["addressline2"], :city => row_data["addresscity"], :state => row_data["addressstate"].try(:upcase), :postal_code => row_data["addresszipcode"])
        end

        if row_data["billingaddressline1"].present?
          customer.addresses.build(:line1 => row_data["billingaddressline1"], :line2 => row_data["billingaddressline2"], :city => row_data["billingaddresscity"], :state => row_data["billingaddressstate"].try(:upcase), :postal_code => row_data["billingaddresszipcode"], :billing => true)
        end
        # set the customer to imported
        customer.imported = true

        if customer.save
          num_saved += 1
        else
          failed_customers << { "#{customer.full_name} Row #{row_num}" || "No name Row #{row_num}" => customer.errors.full_messages.join(',') }
          # Just save customer name so the user can fill in contact info later if there is a validation error
          customer = current_user.customers.build(:first_name => row_data["firstname"], :last_name => row_data["lastname"], :company_name => row_data["companyname"], :active => is_active, :allow_duplicate => al_dup, :imported => true )
           
          customer.save
          
                     
          num_error += 1
        end
      end
    ensure
      # explicitly close your temp import files
      import_file_local_copy.close
      import_file_local_copy.unlink
    end
    return num_saved, num_error, failed_customers
  end

  def self.import_attached_notes(file, user_id)
    current_user = User.find_by_id(user_id)
    num_saved, num_error = 0, 0
    
    CSV.foreach(file.path, :headers => true) do |row|
      
      row_data = {}
      row.to_hash.each_pair do |k, v|
        if not k.nil?
          row_data[k.downcase.strip.delete(' ')] = v
        end
      end    
      
      # Instantiate customer object to find corresponding database record
      customer = current_user.customers.build(:first_name => row_data["firstname"], :last_name => row_data["lastname"], :company_name => row_data["companyname"])
      customer.phone_numbers.build(:phone_number => row_data["phonenumber"].present? ? row_data["phonenumber"].gsub(/\D/, '') : nil)
      customer.emails.build(:address => row_data["email"].try(:downcase))
      customer.addresses.build(:line1 => row_data["addressline1"], :line2 => row_data["addressline2"], :city => row_data["addresscity"], :state => row_data["addressstate"].try(:upcase), :postal_code => row_data["addresszipcode"])

      matching_records = customer.get_possible_duplicates
      
      if matching_records.size > 0 && matching_records.first.attached_notes.build(:body => row_data["note"]).save
        num_saved += 1
      else
        num_error += 1
      end     
    end
  
    return num_saved, num_error
  end
  
  def self.import_appointments(file, user_id)
    
    current_user = User.find_by_id(user_id)
    num_saved, num_error = 0, 0
    
    status_id = current_user.statuses.find_by_name("Active").id
    
    CSV.foreach(file.path, :headers => true) do |row|
      
      row_data = {}
      row.to_hash.each_pair do |k, v|
        if not k.nil?
          row_data[k.downcase.strip.delete(' ')] = v
        end
      end    
      
      # Instantiate customer object to find corresponding database record
      customer = current_user.customers.build(:first_name => row_data["firstname"], :last_name => row_data["lastname"], :company_name => row_data["companyname"])
      customer.phone_numbers.build(:phone_number => row_data["phonenumber"].present? ? row_data["phonenumber"].gsub(/\D/, '') : nil)
      customer.emails.build(:address => row_data["email"].try(:downcase))
      customer.addresses.build(:line1 => row_data["addressline1"], :line2 => row_data["addressline2"], :city => row_data["addresscity"], :state => row_data["addressstate"].try(:upcase), :postal_code => row_data["addresszipcode"])
      
      matching_records = customer.get_possible_duplicates
      
      if matching_records.size > 0
        
        subscription = matching_records.first.subscriptions.build
        
        if row_data["starttime"].present?
          start_time = Time.zone.parse(DateTime.strptime(row_data["starttime"], '%m/%d/%Y %H:%M').strftime('%d/%m/%Y %H:%M'))          
        end
        
        if row_data["endtime"].present?
          end_time = Time.zone.parse(DateTime.strptime(row_data["endtime"], '%m/%d/%Y %H:%M').strftime('%d/%m/%Y %H:%M'))          
        end

        if row_data["starttime"].present? || row_data["endtime"].present?
          if row_data["starttime"].blank?
            start_time = end_time - 2.hours
          end
          
          if row_data["endtime"].blank?
            end_time = start_time + 2.hours
          end
                  
          appointment = subscription.appointments.build(:start_time => start_time, :end_time => end_time, :notes => row_data["notes"], :price => row_data["price"], :status_id => status_id)
          
          if customer.addresses.first.valid?
            appointment.address = customer.addresses.first.dup
          else
            appointment.build_address(:line1 => "Placeholder Address")
          end
          
          if subscription.save
            num_saved += 1
          else
            num_error += 1
          end
        else
          num_error += 1
        end
        
      else
        num_error += 1
      end     
    end
    
    return num_saved, num_error 
  end

  def self.filtered_customers(current_user, params)
    if params[:query]
      q = params[:query].downcase.strip
      where_string = 'lower(first_name) = ? OR lower(last_name) = ? OR lower(company_name) = ? OR phone_numbers.phone_number = ? 
                      OR lower(marketing_source) = ? OR emails.address = ? OR lower(addresses.line1) LIKE ? OR lower(custom_items.value_name) = ?'
      customers = current_user.customers.includes(:emails, :phone_numbers, :addresses, :customer_items).where(where_string, q, q, q, q.gsub(/[^\d.]/, ""), q, q, "%#{q}%", q)
    else
      if params[:filter] == 'customers'
        customers = current_user.customers.where(:lead => false).includes(:emails, :phone_numbers)
      elsif params[:filter] == 'leads'
        customers = current_user.customers.where(:lead => true).includes(:emails, :phone_numbers)
      else
        customers = current_user.customers.includes(:emails, :phone_numbers)
      end

      if ['first_name', 'last_name', 'company_name'].include?(params[:sort_by])
        sort_by_field = params[:sort_by] 
      else
        sort_by_field = 'first_name'
      end

      # filtering by first letter
      if params[:letter] && params[:letter] != 'All'
        customers = customers.where("substr(upper(#{sort_by_field}),1,1) = ?", params[:letter])
      end
      customers.order("#{sort_by_field} ASC")
    end
  end


  def to_csv_row(fields)
    #default
    result = [first_name, last_name, company_name]
    #email
    result << emails.first.try(:address) if fields.include?('emails')
    # export phone numbers
    ['Home', 'Cell', 'Work', 'Spouse'].each do |type|
      if fields.include?("#{type} Phone".parameterize.underscore)
        result << ApplicationController.helpers.formatted_phone_number(self.phone_numbers.find{|pn| pn.phone_number_type == type }.try(:phone_number))
      end
    end

    #address
    if fields.include?('address')
      if  self.addresses.first.present?  
        address = self.addresses.first
        result << "#{address.line1}, #{address.city}, #{address.state} #{address.postal_code}"
      else
        result << nil
      end
    end

    #notes 
    result << self.notes if fields.include?('notes')

    #customer_items
    self.user.customer_fields.pluck(:field_name).each do |field|
      if fields.include?(field.parameterize.underscore)
        # For some reason, sometimes a customer record doesn't have a customer_item for a given customer_field
        # Not sure what the source of this bug is
        result << self.customer_items.find{|item| item.custom_field.field_name == field}.try(:value_name)
      end
    end

    result
  end

  def self.export_to_csv(customers, additional_fields)
    fields = ['first_name', 'last_name', 'company_name'] + additional_fields
    header = fields.map{|w| w.gsub('_', ' ').titleize}

    file = CSV.generate do |csv|
        csv << header if not header.blank?
        customers.map {|customer| csv << customer.to_csv_row(fields)}
    end
    file
  end

end
