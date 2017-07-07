# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  email                     :string(255)      default(""), not null
#  encrypted_password        :string(255)      default(""), not null
#  reset_password_token      :string(255)
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0)
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :string(255)
#  last_sign_in_ip           :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  phone_number              :string(255)
#  plan_id                   :string(255)
#  stripe_customer_token     :string(255)
#  preferences               :text
#  marketing_plan            :boolean          default(FALSE)
#  company_name              :string(255)
#  last_used_payroll_number  :integer          default(0)
#  active                    :boolean          default(TRUE)
#  completed_onboarding      :boolean          default(FALSE)
#  onboarding_page           :integer          default(1)
#  allow_employee_sign_in    :boolean          default(FALSE)
#  default_employee_password :string(255)
#  default_pay_type          :string(255)
#  default_pay_rate          :decimal(8, 2)
#  free_trial_end            :datetime
#  allow_cc_processing       :boolean          default(FALSE)
#  booking_form_started      :boolean          default(FALSE)
#  qb_access_token           :string(255)
#  qb_access_secret          :string(255)
#  qb_company_id             :string(255)
#  qb_token_expires_at       :datetime
#  qb_reconnect_token_at     :datetime
#  qb_syncing                :boolean          default(FALSE)
#  qb_last_sync              :datetime
#  converted_at              :datetime
#  mailchimp_last_sync       :datetime
#  mailchimp_syncing         :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  include PhoneNumberHelper
  include ApplicationHelper

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :customers_attributes, :phone_number, :appointment_fields_attributes, :user_profile_attributes, :base_price, 
    :instant_booking_profile_attributes, :customer_fields_attributes, :employee_fields_attributes, :instructions_attributes, :employees_attributes, :email_templates_attributes, :text_templates_attributes,
    :statuses_attributes, :teams_attributes, :unassigned_color, :no_team_color, :default_calendar_coloring, :send_daily_digest, :company_name, :instant_booking_fields_attributes, :service_types_attributes,
    :allow_employee_sign_in, :default_employee_password, :default_pay_rate, :default_pay_type, :full_name, :payroll_timing, :free_trial_end, :active, :allow_cc_processing,
    :payment_gateway_attributes, :card_number, :expiry_month,:expiry_year, :cvc, :booking_form_started, :converted_at, :plan_id, :expiry_date


  attr_accessor :unassigned_color, :full_name, :payroll_timing, :card_number, :cvc,  :api_error, :expiry_month,:expiry_year, :expiry_date

  serialize :preferences, Hash
  
  has_many :customers, :dependent => :destroy
  has_many :active_customers, :class_name => "Customer", :foreign_key => 'user_id', :conditions => {:active => true}

  has_many :credit_cards, :through => :customers
  
  has_many :employees, :dependent => :destroy
  has_many :service_types, :dependent => :destroy
  
  has_many :instructions, :dependent => :destroy
  
  has_many :custom_fields, :dependent => :destroy
  has_many :employee_fields, :class_name => "CustomField", :conditions => {:field_type => 'employee'}
  has_many :customer_fields, :class_name => "CustomField", :conditions => {:field_type => 'customer'}
  has_many :appointment_fields, :class_name => "CustomField", :conditions => {:field_type => 'appointment'}
  has_one :marketing_field, :class_name => "CustomField", :conditions => {:field_type => 'marketing'}

  has_many :instant_bookings, :through => :service_types, :dependent => :destroy
  has_many :instant_booking_fields, :class_name => "CustomField", :conditions => {:field_type => 'instant_booking'}
  
  has_many :subscriptions, :through => :customers, :as => :subscriptionable
  has_many :appointments, :through => :subscriptions
  
  has_many :log_entries, :through => :appointments
  
  has_many :pricing_tables, :dependent => :destroy
  has_many :statuses, :dependent => :destroy
  has_many :teams, :dependent => :destroy
  
  has_one :user_profile, :dependent => :destroy
  has_one :instant_booking_profile, :dependent => :destroy
  has_many :email_templates, :dependent => :destroy
  has_many :text_templates, :dependent => :destroy
  
  has_many :payrolls, :dependent => :destroy
  has_many :payroll_entries, :through => :payrolls
  
  has_many :tasks, :dependent => :destroy
  has_many :task_recurrences, :dependent => :destroy

  has_one :payment_gateway, :dependent => :destroy, :inverse_of => :user
  has_one :auth, :dependent => :destroy, :inverse_of => :user

  accepts_nested_attributes_for :customers, :employees, :appointment_fields, :customer_fields, :employee_fields, :user_profile, 
    :instant_booking_profile, :instructions, :employees, :email_templates, :text_templates, :statuses, :teams, :service_types, 
    :instant_booking_fields, :payment_gateway, :allow_destroy => true
  
  before_validation do |user|
    user.phone_number = strip_nondigits_from_phone_number phone_number if phone_number.present?
  end

  before_save do |user|
    if user.plan_id_changed? && user.plan_id_was.present?
      user.change_plan
    end
  end
  
  #validates :phone_number, :length => {:minimum => 10, :maximum => 11, :message => " must be a valid phone number with area code"}, :if => Proc.new { |user| user.new_record? }
  #validates :company_name, :presence => true
  #validates_presence_of :full_name, :if => Proc.new { |user| user.new_record? }
  validate :email_not_taken_by_employee, :if => Proc.new { |user| user.new_record? }

  # Errors added outside of validation callbacks are wiped when the model is saved. Do this to keep errors around
  validate :add_api_error_to_base, :if => Proc.new { |user| user.new_record? }
   

  # TODO: Can only handle one error for now, couldn't figure out how to initialize a virtual attribute as an array
  def add_api_error_to_base
    if self.api_error.present?
      errors[:base] << self.api_error
    end
  end

  def create_plan
    begin
      subscribed = false
      if self.email.present? && self.persisted?
        customer = Stripe::Customer.create(
          :email => self.email, 
          :description => "#{self.email} CUSTOMER", 
          :card => {
            :number => self.card_number,
            :exp_month => self.expiry_month,
            :exp_year => self.expiry_year,
            :cvc => self.cvc
            }, 
          :plan => self.plan_id
        )
        self.stripe_customer_token = customer.id
        self.converted_at = Time.zone.now
        self.save

        subscription = customer.subscriptions.all.first
        subscription.trial_end = "now"
        res = subscription.save
        subscribed = true if res.plan.name == self.plan_id
      
      end
      subscribed
      
    rescue => e
      self.api_error = e.message
      return false
    end 

  end

  def change_plan
    changed = false
    begin
      customer = Stripe::Customer.retrieve(self.stripe_customer_token)
      subscription = customer.subscriptions.all.first
      subscription.plan = self.plan_id
      subscription.trial_end = "now"
      res = subscription.save
      changed = true if res.plan.name == self.plan_id
    rescue => e
    end

    changed
  end
 
  def email_not_taken_by_employee
    if Employee.where(:email => self.email).count > 0
      errors.add(:email, "has already been registered as an employee for another company")
    end
  end

  def expiry_date
    if @expiry_date.present?
       @expiry_date
    else 
      self.expiry_month.present? ? "#{expiry_month}/#{expiry_year}" : ""
    end
  end

  def expiry_date=(input)
    @expiry_date = input
    split_date = @expiry_date.split("/")

    self.expiry_month = split_date[0]
    self.expiry_year = split_date[1]

  end


  def password_fields_valid?
    self.errors[:password].blank? && self.errors[:password_confirmation].blank?
  end
  
  def send_daily_digest=(val)
    self.preferences[:send_daily_digest] = string_to_boolean val
  end
  
  def send_daily_digest
    self.preferences[:send_daily_digest]
  end
  
  def unassigned_color=(color)
    self.preferences[:unassigned_color] = color
  end
  
  def unassigned_color
    self.preferences[:unassigned_color]
  end
  
  def no_team_color=(color)
    self.preferences[:no_team_color] = color
  end
  
  def no_team_color
    self.preferences[:no_team_color]
  end
  
  def default_calendar_coloring=(color_source) 
    self.preferences[:default_calendar_coloring] = color_source
  end
  
  def default_calendar_coloring
    self.preferences[:default_calendar_coloring]
  end
  
  def update_or_subscribe_to_plan(hash={})
    if hash[:coupon].blank?
      hash.delete(:coupon)
    end
    
    if hash[:stripeToken].present?
      customer = Stripe::Customer.create(:email => self.email, :description => "User ID #{self.id}", :card => hash[:stripeToken], :plan => hash[:plan_id], :coupon => hash[:coupon])
      self.plan_id = hash[:plan_id]
      self.stripe_customer_token = customer.id
      self.active = true
      self.save!
    end
  end
  
  def create_all_missing_custom_items(resource)
    # Note: appointment items and instructions are currently created in the edit action when calling the appointment.rb model
    if resource == "customer"
      self.customers.each do |customer|
        (self.customer_fields.map(&:id) - customer.customer_items.map(&:custom_field_id)).each do |id|
          item = customer.customer_items.build(:custom_field_id => id)
          item.save!
        end
      end
    end

    if resource == "employee"
      self.employees.each do |employee|
        (self.employee_fields.map(&:id) - employee.employee_items.map(&:custom_field_id)).each do |id|
          item = employee.employee_items.build(:custom_field_id => id)
          item.save!
        end
      end
    end
        
  end
  
  def build_default_entries(template_user_email = "maidmarketing@template.com", free_trial_length = 14.days)
    
    # Eventually, will probably want to get rid of user_profile model
    profile = self.build_user_profile
    #profile.company_name = self.company_name
    profile.company_email = self.email
    #profile.company_phone_number = self.phone_number

    # Builds first employee and links it as the owner account
    self.build_owner_employee

    template_user = User.find_by_email(template_user_email)
    if template_user.blank?
      self.save
      return
    end

    self.marketing_plan = template_user.marketing_plan

    template_user.statuses.each do |status|
      self.statuses << status.dup
    end

    self.preferences = template_user.preferences

    if self.preferences[:instant_booking]
      self.build_instant_booking_profile
    end

    template_user.instructions.each do |instruction|
      self.instructions << instruction.dup
    end
    
    template_user.service_types.each do |service_type|
      self.service_types << service_type.dup
    end
    
    template_user.customer_fields.each do |customer_field|
      self.customer_fields << customer_field.dup
    end

    template_user.employee_fields.each do |employee_field|
      self.employee_fields << employee_field.dup
    end
    
    template_user.instant_booking_fields.each do |instant_booking_field|
      self.instant_booking_fields << instant_booking_field.dup
    end
    
    template_user.appointment_fields.each do |appointment_field|
      self.appointment_fields << appointment_field.dup
    end
    
    template_user.email_templates.each do |email_template|
      self.email_templates << email_template.dup
    end
    
    template_user.text_templates.each do |text_template|
      self.text_templates << text_template.dup
    end
    
    self.build_marketing_field(:input_type => 'select', :field_type => 'marketing', :field_name => "Marketing Source")

    self.payment_gateway = template_user.payment_gateway.dup

    self.free_trial_end = Time.zone.now.beginning_of_day + free_trial_length

    self.save
    
    # Adjust service_type_ids on instant_booking_fields to point to current account service_type_ids
    service_type_id = self.service_types.try(:first).try(:id)
    self.instant_booking_fields.update_all(:service_type_id => service_type_id)
    
    # Make initial appointment
    self.seed_sample_customers_and_appointments(template_user)

    # Adjust statuses_ids on email and text templates to point to the current account statuses
    self.adjust_template_statuses

  end

  def build_owner_employee
      employee = self.employees.build(:email => self.email, :phone_number => self.phone_number)
      if self.full_name.present?
        parsed_name = parse_name(self.full_name)
        employee.first_name = parsed_name[:first_name]
        employee.last_name = parsed_name[:last_name]
      else
        employee.first_name = "Owner"
      end
      
      employee.owner = true
      employee.allow_sign_in = true
      employee.assignable = true
      employee.admin = true
      
      employee.encrypted_password = self.encrypted_password

  end
 
  def adjust_template_statuses
    self.email_templates.each do |template|
      if template.after_status.present?
        template.after_status = self.statuses.find_by_name(Status.find_by_id(template.after_status).name).id
        template.save
      end
    end

    self.text_templates.each do |template|
      if template.after_status.present?
        template.after_status = self.statuses.find_by_name(Status.find_by_id(template.after_status).name).id
        template.save
      end      
    end
  end

  def seed_sample_customers_and_appointments(template_user)
      template_customers = template_user.customers

      template_customers.each do |template_customer|
        c = template_customer.dup
        c.user_id = self.id
        c.allow_duplicate = true
        template_customer.emails.each do |email|
          c.emails << email.dup
        end
        template_customer.phone_numbers.each do |phone_number|
          c.phone_numbers << phone_number.dup
        end
        template_customer.addresses.each do |address|
          c.addresses << address.dup
        end
        self.customer_fields.each do |customer_field|
          c.customer_items.build(:custom_field_id => customer_field.id, :value_name => "Example Value")
        end
        c.save

        template_subscription = template_customer.subscriptions.first
        s = template_subscription.dup
        s.subscriptionable_id = c.id

        # Does not duplicate appointment service items, custom fields, or assignments for user seeds. Does duplicate address
        # New users don't have any appointment service items/custom fields anyways
        a = template_subscription.appointments.first.dup_with_repeatable_associations(for_user_seeding = true)

        # Keep weekday and time for duplicated appointments the same, but move to current week
        new_time = Time.zone.now + (a.start_time.wday - Time.zone.now.wday).days        
        a.start_time = new_time.change({:hour => a.start_time.hour, :min => a.start_time.min})
        a.end_time = new_time.change({:hour => a.end_time.hour, :min => a.end_time.min})

        a.status_id = self.statuses.find_by_name("Active").id
        s.appointments << a
        s.save
      end

  end

  def cancel_subscription
    cancelled = false
    begin
      customer = Stripe::Customer.retrieve(self.stripe_customer_token)
      subscription = customer.subscriptions.all.first
      res = subscription.delete
      cancelled = true if res.status == 'canceled'
    rescue Exception => e
    end
    cancelled
  end

  def mailchimp_auth_exists?
    mailchimp_auth.present?
  end

  def mailchimp_auth
    self.auth    
  end

end
