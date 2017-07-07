# == Schema Information
#
# Table name: appointments
#
#  id                :integer          not null, primary key
#  subscription_id   :integer
#  start_time        :datetime
#  end_time          :datetime
#  paid              :boolean          default(FALSE)
#  cancelled         :boolean          default(FALSE)
#  assigned          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  requests          :text
#  confirmed         :boolean          default(FALSE)
#  price             :decimal(8, 2)
#  notes             :text
#  service_type_id   :integer
#  use_as_prototype  :boolean          default(FALSE)
#  status_id         :integer
#  assignments_count :integer          default(0)
#  team_id           :integer
#  sent_on           :text
#  payroll_id        :integer
#

class Appointment < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include ApplicationHelper
  include AppointmentsHelper
  include PhoneNumberHelper

  attr_accessible :end_time, :start_time, :subscription_id, :customer_attributes, :address_attributes, :appointment_service_items_attributes, :assignments_attributes, :start_time_date, :start_time_time,
    :confirmed, :paid, :notes, :price, :requests, :service_type_id, :end_time_date, :end_time_time, :appointment_items_attributes, :status_id, :team_id, :assign_to, :sent_on, :allow_conflicts, :assignments_count,
    :use_as_prototype, :payroll_id

  attr_accessor :start_time_date, :start_time_time, :end_time_time, :end_time_date, :already_saved, :update_constraints, :assign_to, :allow_conflicts

  serialize :sent_on, Hash

  belongs_to :subscription, :inverse_of => :appointments
  belongs_to :service_type
  belongs_to :status
  belongs_to :team
  belongs_to :payroll

  has_one :address, :as => :addressable, :dependent => :destroy

  has_one :instant_booking
  has_many :appointment_service_items, :dependent => :destroy
  has_many :appointment_items, :as => :customizable, :class_name => "CustomItem", :dependent => :delete_all
  has_many :log_entries, :dependent => :destroy
  has_many :assignments, :dependent => :destroy, :inverse_of => :appointment
  has_many :employees, :through => :assignments

  # Magic to make join through polymorphic association work
  has_one :customer, :through => :subscription, :source => :subscriptionable, :source_type => "Customer"
  has_one :user, :through => :customer

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :assignments, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :appointment_service_items, :allow_destroy => true
  accepts_nested_attributes_for :appointment_items, :allow_destroy => true

  validates_presence_of :start_time, :start_time_time, :start_time_date, :end_time_time, :end_time_date
  validates :price, :format => { :with => /^\d+??(?:\.\d{0,2})?$/, :message => "must be a valid US Dollar Amount (e.g., $1.00 or $1)"}, :numericality => {:greater_than_or_equal_to => 0, :less_than => 1000000}, :allow_blank => true
  validate :end_time_greater_than_start_time
  validate :no_conflicts, :unless => Proc.new { |a| string_to_boolean(a.allow_conflicts) }

  scope :previous, where("appointments.start_time < ?", Time.zone.now)
  scope :future, where("appointments.start_time > ?", Time.zone.now)
  scope :ascending, order("appointments.start_time ASC")
  scope :descending, order("appointments.start_time DESC")
  scope :actual, ->{ where("appointments.use_as_prototype = ?", false)}
  scope :not_id, ->(appointment_id){ where(['appointments.id <> ?', appointment_id])}
  scope :active, ->{ joins(:status).where('statuses.show_by_default = ?', true)}
  scope :payrollable, ->{ joins(:status).where('statuses.use_for_payroll = ?', true)}

  # Don't do destroy callback when disabling a subscription to avoid doing callback on every deleted appointment
  before_destroy :update_subscription_constraints, :if => :update_constraints

  # Make sure user is loaded in the case that the customer is booking through a nested form
  before_validation do |appointment|
    if price.present? && !is_numeric?(price_before_type_cast)
      appointment.price = format_price_for_save price_before_type_cast
    end

    if appointment.start_time_date.present? && appointment.start_time_time.present?
      appointment.start_time = Time.zone.parse("#{appointment.start_time_date} #{appointment.start_time_time}")
    end

    # Don't consider appointments spanning multiple days for now
    if appointment.start_time.present? && appointment.end_time_time.present?
      appointment.end_time = Time.zone.parse("#{appointment.start_time_date} #{appointment.end_time_time}")
    end

  end

  # Any changes to either the appointment or subscription for appointment-related recurring info are handled here
  before_save do |appointment|

    appointment.subscription.adjust_recurrence_based_on_repeat_attribute

    # Check if a change has occured to recurrence or to appointment 'repeatable' data
    if !appointment.new_record? && !appointment.already_saved && (appointment.subscription.recurrence_changed? or appointment.self_or_associated_data_changed?)

      logger.debug "ADJUSTING APPOINTMENT"
      # Make sure before_save callbacks are only fired once
      appointment.already_saved = true

      # Make sure that recurrence is up to date with form fields
      if appointment.subscription.frequency > 0
        if appointment.subscription.frequency_was == 0
          logger.debug "BEFORE SAVE frequency > 0 and was = 0"
          appointment.subscription.start_time = appointment.start_time
          appointment.subscription.end_time = appointment.end_time

          appointment.use_as_prototype = true
          appointment.subscription.prepopulate_appointments
          appointment.subscription.save!
        else
          logger.debug "BEFORE SAVE ADJUSTING RECURRING SUBSCRIPTION"
          appointment.adjust_recurring_subscription
        end
      else
        if appointment.subscription.frequency_was > 0
          logger.debug "BEFORE SAVE frequency = 0 and was > 0"
          appointment.subscription.disable(appointment.end_time_was, appointment.id)

          # Save subscription with end date set to day of appointment, need to set virtual attribute repeat to nil
          # since these attributes persist after reloading and if it is set to false then the subscription frequency and interval will be set to 0
          # TODO: Find more intuitive and simple way of managing this logic
          appointment.subscription.reload
          appointment.subscription.repeat = nil
          appointment.subscription.constraints[:end_date] = appointment.start_time.beginning_of_day
          appointment.subscription.save!
        end
      end
    end

    # Make sure to return true so that records are saved
    return true
  end

  before_create do |appointment|
    log_entry = appointment.log_entries.build(:log_type => "Creation", :entry => "Appointment was scheduled for #{appointment.start_time.strftime("%-m/%d/%Y")} #{appointment_time_to_string(appointment.start_time, appointment.end_time)}")
  end

  before_update do |appointment|

    if appointment.status_id_changed?
      log_entry = appointment.log_entries.build(:log_type => "Status", :entry => "Status for appointment on #{appointment.start_time.strftime("%-m/%d/%Y")} #{appointment_time_to_string(appointment.start_time, appointment.end_time)} was changed from #{Status.find_by_id(appointment.status_id_was).name} to #{appointment.status.name}")
      log_entry.save!
    end

    #if appointment.start_time_changed?
    #  appointment.template_jobs.each do |job|
    #    job.update_time(start_time)
    #  end
    #end

    if appointment.start_time_changed? or appointment.end_time_changed?
      log_entry = appointment.log_entries.build(:log_type => "Reschedule", :entry => "Appointment on #{appointment.start_time_was.strftime("%-m/%d/%Y")} #{appointment_time_to_string(appointment.start_time_was, appointment.end_time_was)} was rescheduled to #{appointment.start_time.strftime("%-m/%d/%Y")} #{appointment_time_to_string(appointment.start_time, appointment.end_time)}")
      log_entry.save!
      
      # update assignment start and end time when appointment is rescheduled
      appointment.assignments.each do |assignment|
        unless assignment.new_record?
          assignment.time_in = appointment.start_time
          assignment.time_out = appointment.end_time
          assignment.save!          
        end
      end
    end

  end

  def no_conflicts
    if self.start_time.present? && self.end_time.present? && self.status.use_for_conflicts? && !self.use_as_prototype? && self.get_conflicts.size > 0
      errors.add(:base, "Conflicts Present")
    end
  end

  def get_conflicts
    if self.start_time.present? && self.end_time.present?
      employee_ids = self.assignments.reject { |a| a.marked_for_destruction? }.map(&:employee_id)
      logger.debug employee_ids
      if self.new_record?
        Employee.includes({:assigned_appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.use_for_conflicts = ?', true).where("appointments.start_time < ? AND appointments.end_time > ?", self.end_time, self.start_time).where("employees.id in (?)", employee_ids)
      else
        Employee.includes({:assigned_appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.use_for_conflicts = ?', true).where('appointments.use_as_prototype = ?', false).where("appointments.start_time < ? AND appointments.end_time > ? AND appointments.id <> ?", self.end_time, self.start_time, self.id).where("employees.id in (?)", employee_ids)
      end
    end
  end

  def update_subscription_constraints
    self.subscription.reload
    if string_to_boolean(self.subscription.apply_to_subscription)
      self.subscription.disable(self.end_time_was)
    end

    self.subscription.save!
  end

  def self_or_associated_data_changed?
    !self.new_record? && (self.changed? or self.address.changed? or self.appointment_service_items.any?(&:changed?) or self.assignments.any?(&:changed?))
  end

  def start_or_end_time_changed?
    !self.new_record? && (self.start_time_changed? or self.end_time_changed?)
  end

  def adjust_recurring_subscription

    if string_to_boolean(self.subscription.apply_to_subscription) or self.subscription.recurrence_changed?
      # if change is applied to subscription, create new subscription and disable old one
      new_subscription = self.subscription.dup
      new_subscription.start_date = self.start_time_date
      new_subscription.parent_id = self.subscription.id

      # Disable old subscription so that new subscription can take its place
      self.subscription.reload
      self.subscription.disable(self.start_time_was, self.id)
      self.subscription.save!

      # this appointment becomes the prototype for the new subscription
      self.payroll_id = nil
      new_subscription.appointments << self
      new_subscription.save!
    end
  end

  def dup_with_repeatable_associations(for_user_seeding = false)

    new_appointment = self.dup

    # stop duplicated virtual start_time_ and end_time_ attributes from overwriting prepopulated time, reset counter_cache on assignments to 0
    new_appointment.attributes = {:start_time_time => nil, :start_time_date => nil, :end_time_time => nil, :end_time_date => nil, :paid => false, :sent_on => nil,
      :allow_conflicts => true, :assignments_count => 0, :use_as_prototype => false, :payroll_id => nil}

    new_appointment.tap do |appointment|
      if !for_user_seeding
        self.appointment_service_items.each do |item|
          appointment.appointment_service_items << item.dup
        end

        self.appointment_items.each do |item|
          new_item = item.dup
          new_item.value_name = nil if item.custom_field.unique?

          appointment.appointment_items << new_item
        end

        self.assignments.each do |assignment|
          new_assignment = assignment.dup
          new_assignment.payroll_entry_id = nil
          appointment.assignments << new_assignment
        end
      end

      appointment.address = self.address.dup

    end
  end


  def build_all_missing_appointment_items(user)
   (user.appointment_fields.map(&:id) - self.appointment_items.map(&:appointment_field_id)).each do |id|
      self.appointment_items.build(:appointment_field_id => id)
    end
  end

  def build_all_missing_assignments(user)
    (user.employees.active.map(&:id) - self.assignments.map(&:employee_id)).each do |id|
      self.assignments.build(:employee_id => id)
    end
  end

  def build_all_missing_service_items(user)
    (user.instructions.map(&:id) - self.appointment_service_items.map(&:instruction_id)).each do |id|
      self.appointment_service_items.build(:instruction_id => id, :field_name => user.instructions.find_by_id(id).field_name)
    end
  end

  def build_all_missing_custom_associations(user)
    #Unnecessary with new schema
    #self.build_all_missing_appointment_items(user)
    
    self.build_all_missing_assignments(user)

    if user.preferences[:service_items_as_checkbox]
      self.build_all_missing_service_items(user)
    end

  end

  def build_template_jobs
    self.subscription.subscriptionable.user.email_templates.each do |template|
      job = self.template_jobs.build(:sendable_id => template.id, :sendable_type => template.class.to_s)
      # job.update_time(self.start_time)
    end
  end

  def initialize_from_booking(instant_booking)
    if instant_booking.present?
      self.start_time = instant_booking.start_time
      self.end_time = self.start_time + 2.hours
      self.service_type_id = instant_booking.service_type_id
      self.price = instant_booking.price
    end
  end

  def end_time_greater_than_start_time
    if self.end_time.present? and self.end_time <= self.start_time
      errors.add(:end_time_time, "must be later than appointment start time")
    end
  end

  def start_time_time
    @start_time_time || start_time.try(:strftime, '%l:%M %p')
  end

  def start_time_date
    @start_time_date || start_time.try(:strftime, '%d/%m/%Y')
  end

  def end_time_time
    @end_time_time || end_time.try(:strftime, '%l:%M %p')
  end

  def end_time_date
    @end_time_date || end_time.try(:strftime, '%d/%m/%Y')
  end

  # Use to make sure that multiple before_save callbacks aren't triggered on the same appointment model
  def already_saved
    @already_saved || false
  end

  def format_price_for_save(price)
    price.gsub(/[^\d\.]/, '')
  end

   def to_csv_row(appointment)
    #appointment info
    job_id              = appointment.subscription.id
    service_date        = appointment.start_time.strftime('%-m/%-d/%Y')
    
    #customer info
    customer = appointment.customer
    client_email        = customer.emails.try(:first).try(:address)
    client_mobile       = formatted_phone_number(customer.phone_numbers.select { |p| p.phone_number_type == "Cell" || p.phone_number_type == "Cell (Don't Text)" }.try(:first).try(:phone_number))
    client_contact_number = formatted_phone_number(customer.phone_numbers.try(:first).try(:phone_number))
    
    #employee info
    employee_names      = appointment.employees.map(&:full_name).join(", ")

    [job_id, service_date, customer.first_name, customer.last_name, customer.contact_name, client_email, client_mobile, client_contact_number, employee_names]
  end

  def self.export_to_csv(appointments)
    header = ['job_id', 'service_date', 'client_first_name', 'client_last_name', 'client_name', 'client_email', 'client_mobile', 'client_contact_number', 'employee_names']
    #header = fields.map{|w| w.gsub('_', ' ').titleize}

    file = CSV.generate do |csv|
      csv << header
      appointments.each do |appointment| 
        csv << appointment.to_csv_row(appointment)
      end
    end

    file
  end

end

