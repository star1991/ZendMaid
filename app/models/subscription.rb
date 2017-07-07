# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  start_time            :datetime         not null
#  end_time              :datetime         not null
#  active                :boolean          default(TRUE)
#  interval              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  frequency             :integer
#  materialized_until    :datetime
#  constraints           :text
#  repeat_on             :text
#  subscriptionable_id   :integer
#  subscriptionable_type :string(255)
#  parent_id             :integer
#  title                 :string(255)
#

class Subscription < ActiveRecord::Base
  include ApplicationHelper

  attr_accessible :active, :frequency, :interval, :repeat, :repeat_until, :apply_to_subscription, :parent_id, :appointments_attributes, :start_time_time, :start_time_date, :end_time_time, :end_time_date, 
    :old_event_start_time, :title, :start_time, :end_time, :start_date, :from_admin_console, :inactivate_on, :day_of_week, :week_of_month, :edit_on, :make_record_customer

  attr_accessor :repeat_until, :apply_to_subscription, :from_admin_console, :inactivate_on, :edit_on, :day_of_week, :week_of_month, :start_time_date, :start_time_time, :end_time_time, :make_record_customer
  
  belongs_to :subscriptionable, :polymorphic => true
  has_many :appointments, :dependent => :destroy, :inverse_of => :subscription
  has_many :log_entries, :through => :appointments

  belongs_to :parent, :class_name => "Subscription"
  has_many :children, :foreign_key => "parent_id", :class_name => "Subscription"
  
  serialize :repeat_on, Array
  serialize :constraints, Hash
  
  validates_presence_of :frequency
  validates_presence_of :start_date, :if => :from_admin_console
  validate :start_date_recent, :if => Proc.new { |s| s.from_admin_console && s.repeat }
  
  # Only validate presence of interval if frequency is not one-time
  validates_presence_of :interval, :unless => Proc.new { |subscription| subscription.try(:frequency) == 0 }
  validates_presence_of :title, :if => Proc.new { |subscription| subscription.subscriptionable_type == 'Employee' }
  
  validate :end_date_greater_than_start, :if => Proc.new { |s| s.new_record? }
  
  scope :has_appointments, joins(:appointments).group('subscriptions.id').where('appointments.use_as_prototype = ?', false).having('count(appointments.id) > 0')


  accepts_nested_attributes_for :appointments
  
  before_validation do |subscription|
   
    # Set recurrence frequency and interval to 0 if repeat form input is false
    subscription.adjust_recurrence_based_on_repeat_attribute
  end
  
  before_save do |subscription|
    
    # Check if subscription recurrence or time has changed on employee obligations
    if !subscription.new_record? and subscription.subscriptionable_type == 'Employee' and (subscription.recurrence_changed? or subscription.start_time_changed? or subscription.end_time_changed?)
     
      if (string_to_boolean(subscription.apply_to_subscription) or subscription.recurrence_changed?) and subscription.frequency_was > 0
        
        if subscription.frequency > 0
          new_subscription = subscription.dup
          new_subscription.save!
        end
        
        subscription.reload
        subscription.constraints[:end_date] = subscription.old_event_start_time
      elsif subscription.frequency_was > 0
        new_subscription = subscription.dup_without_repeats
        new_subscription.save!
        
        subscription.reload
        subscription.constraint[:skip_times] << subscription.old_event_start_time
      end
    end
    
    return true
  end
  
  # TODO: Move this code to worker after creation to improve UI responsiveness and remove memory leak
  ##############################
  # KNOWN MEMORY LEAK
  #
  # Prepopulated appointments are initialized in memory all at once
  # These records seem to persist on the server instead of being destroyed
  # Possible solution -- start garbage collector after record is saved?
  # UPDATE 4/6/2014 Possibly fixed by upgrade to Ruby 1.9.3
  ##############################
  before_create do |subscription|
    logger.debug "before create called subscription"

    if subscription.appointments.size > 0
      # Should have only one linked appointment before creation of subscription
      subscription.start_time = appointments.first.start_time
      subscription.end_time = appointments.first.end_time
      subscription.start_date = subscription.start_time_date
      
      subscription.constraints[:skip_times] = []
      subscription.materialized_until = subscription.start_time
      subscription.active = true
      
      # Only prepopulate if subscription is recurring
      if subscription.frequency > 0

        prototype_appointment = subscription.appointments.first.dup_with_repeatable_associations
        prototype_appointment.use_as_prototype = true
        subscription.appointments << prototype_appointment

        subscription.prepopulate_appointments
      else
        subscription.materialized_until = subscription.start_time
      end
    end

  end
  
  def appointment_prototype
    if self.new_record?
      self.appointments.select(&:use_as_prototype?).first
    else
      self.appointments.find_by_use_as_prototype(true) || self.appointments.select(&:use_as_prototype?).first
    end
  end
  
  
  def repeat
    read_attribute(:repeat).nil? ? (frequency.nil? ? false : frequency > 0) : read_attribute(:repeat)
  end
  
  def repeat=(repeat_string)
    self[:repeat] = string_to_boolean(repeat_string)
  end
  
  def repeat_until
    @repeat_until || constraints[:end_date].try(:strftime, '%d/%m/%Y')
  end
  
  def repeat_until=(repeat_date)
    if repeat_date.present?
      self.constraints[:end_date] = Time.zone.parse(repeat_date)
    end
    
  end
  
  def start_date
    @start_date || constraints[:start_date].try(:strftime, '%d/%m/%Y')
  end
  
  def start_date=(start_date)
    if start_date.present?
      self.constraints[:start_date] = Time.zone.parse(start_date)
    end
  end
  
  def adjust_recurrence_based_on_repeat_attribute
    if not self.repeat
      self.frequency = 0
      self.interval = 0
    end
  end
  
  def end_date_greater_than_start
    if self.constraints[:end_date].present? and self.constraints[:start_date].present? and self.constraints[:end_date] <= self.constraints[:start_date]
      errors.add(:repeat_until, "must be later than start date")
    end
  end
  
  def start_date_recent
    if self.constraints[:start_date].present? and self.constraints[:start_date].year < Time.zone.now.year - 5
      errors.add(:start_date, "must not be less than five years ago")
    end
  end
  
  def prepopulate_appointments(time_forward = 6.months, appointment_prototype=nil)
  
    appointment_prototype = self.appointment_prototype
    if appointment_prototype.blank?
      return nil
    end
    
    appointment_length = appointment_prototype.end_time - appointment_prototype.start_time
    first_start_time = appointment_prototype.start_time
    
    current_start_time = first_start_time
    while (next_start_time = self.calculate_next_valid_start_time current_start_time) and next_start_time < Time.zone.now + time_forward
      appointment = appointment_prototype.dup_with_repeatable_associations
      appointment.start_time = next_start_time
      appointment.end_time = next_start_time + appointment_length
      self.appointments << appointment
      current_start_time = next_start_time
    end
    
    appointment_prototype.start_time = current_start_time
    appointment_prototype.end_time = current_start_time + appointment_length
    
    if self.calculate_next_valid_start_time(current_start_time).blank?
      self.active = false
    end
    
    # To avoid possible duplication of appointments on future calls to prepopulate
    # Don't know when this case would arise, but better to be safe than sorry
    if current_start_time >= self.materialized_until
      self.materialized_until = current_start_time
    end
    
  end

  def get_valid_start_times_between(interval_start, interval_end)
    start_time = self.start_time
    event_length = self.end_time - self.start_time
    
    valid_events = []
    while start_time and start_time <= interval_end
      if start_time >= interval_start and start_time <= interval_end
        valid_events << {:title => self.title, :start => "#{start_time.iso8601}", :end => "#{(start_time + event_length).iso8601}", :allDay => false}
      end
      
      start_time = calculate_next_valid_start_time(start_time)
    end
    
    return valid_events
  end

  def calculate_next_valid_start_time(start_time)
    if not self.repeat
      return nil
    end
    
    start_time = self.calculate_next_start_time start_time
    
    while start_time <= self.materialized_until
      start_time = self.calculate_next_start_time(start_time)
    end
    
    # Return nil if next valid start time is greater than the subscription's end date
    if not self.constraints[:end_date] or start_time < self.constraints[:end_date]
      return start_time
    else
      return nil
    end
  end
  
  def calculate_next_start_time(start_time)
    week_number = self.start_time.day / 7
    
    case self.frequency
    when 1
      start_time + self.interval.days
    when 2
      start_time + self.interval.weeks
    when 3
      # get next instance of day of week (i.e., third Thursday two months from now, etc.)
      next_weekday(start_time, self.interval, week_number)
    when 4
      # same as month, but with year instead (i.e., closest Thursday 1 year from now, etc.)
      next_weekday(start_time, 12*self.interval, week_number)
    else
      nil
    end
  end
   
  def next_weekday(current_time, num_months, week_number)
     month_begin = (current_time + num_months.months).beginning_of_month.change(:hour => current_time.hour, :min => current_time.min, :sec => current_time.sec)
  
     first_wday_of_month = month_begin + ((current_time.wday - month_begin.wday) % 7).days
     
     next_time = first_wday_of_month + week_number.weeks
     
     #roll back a week if we overshoot month
     if next_time.month != month_begin.month
       next_time = next_time - 1.weeks
     end
     
     return next_time
  end
  
  def dup_without_repeats
    new_subscription = self.dup
    
    new_subscription.tap do |subscription|
      subscription.constraints = {}
      subscription.frequency = 0
      subscription.interval = 0
      subscription.materialized_until = nil
      subscription.parent_id = self.id
    end
  end
  
  # Returns false if new record
  def recurrence_changed?
    !self.new_record? && (self.frequency_changed? or self.interval_changed? or self.constraints_changed?)
  end
  
  def disable(end_time, not_id = 0)
    self.appointments.actual.not_id(not_id).where(["appointments.start_time > ?", end_time]).destroy_all
    
    self.constraints[:end_date] = end_time
    
    if end_time <= self.materialized_until
      self.active = false
    end 
  end

  def day_of_week
    @day_of_week || start_time.try(:wday)
  end

  def week_of_month
    @week_of_month || self.start_time.day/7 + 1
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
  
end
