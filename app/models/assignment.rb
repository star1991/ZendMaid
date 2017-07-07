# == Schema Information
#
# Table name: assignments
#
#  id                 :integer          not null, primary key
#  employee_id        :integer
#  role               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  appointment_id     :integer
#  work_order_sent_on :datetime
#  time_in            :datetime
#  time_out           :datetime
#  set_manually       :boolean          default(FALSE)
#  payroll_entry_id   :integer
#  job_wage           :decimal(8, 2)    default(0.0)
#  extras             :decimal(8, 2)    default(0.0)
#  total              :decimal(8, 2)    default(0.0)
#  pay_type           :string(255)
#  pay_rate           :decimal(, )
#

#

class Assignment < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :employee_id, :role, :time_in, :time_out, :use_appointment_date, :job_wage, :extras, :updated_from_payroll_entry, :reset_job_wage
  attr_accessor :use_appointment_date, :duration, :updated_from_payroll_entry, :reset_job_wage

  
  belongs_to :appointment, :counter_cache => true, :inverse_of => :assignments
  belongs_to :employee
  belongs_to :payroll_entry
  
  before_update do |assignment|
    if assignment.use_appointment_date
      start_time = assignment.appointment.start_time
      assignment.time_in = assignment.time_in.try(:change, {:year => start_time.year, :month => start_time.month, :day => start_time.day})
      assignment.time_out = assignment.time_out.try(:change, {:year => start_time.year, :month => start_time.month, :day => start_time.day})
    end
  end
  
  before_create do |assignment|
    # Set time_in and time_out of assignments to appointment start and end time on object creation
    assignment.time_in = assignment.appointment.start_time
    assignment.time_out = assignment.appointment.end_time
  end
  
  # Need to strip nondigits or field will be erroneously set as 0
  before_validation :set_wage_and_extras_properly, :if => Proc.new { |assignment| assignment.updated_from_payroll_entry.present? }
  after_validation :set_job_wage, :if => Proc.new { |assignment| assignment.reset_job_wage.present? }
  
  before_update :update_total
  after_update :update_payroll_entry, :if => Proc.new { |assignment| assignment.payroll_entry_id.present? && assignment.updated_from_payroll_entry.present? && assignment.total_changed? }

  validate :end_time_greater_than_start_time


  def set_job_wage
    case self.pay_type
    when 'Hourly'
      self.job_wage = self.pay_rate * (self.duration) / 1.hour
    when 'Revenue Share'
      if self.appointment.price.present?
        self.job_wage = self.pay_rate * self.appointment.price / 100
      else
        self.job_wage = 0
      end
    when 'Fixed Flat Rate'
      self.job_wage = self.pay_rate
    else
      self.job_wage = 0
    end
    
    self.total = self.job_wage + self.extras
  end
  
  def time_in_time
    @time_in_time || time_in.try(:strftime, '%l:%M %p') || "<strong class='red'>Not Set</strong>".html_safe
  end

  def time_out_time
    @time_out_time || time_out.try(:strftime, '%l:%M %p') || "<strong class='red'>Not Set</strong>".html_safe
  end
  
  def duration
    if time_in.present? && time_out.present?
      @duration ||= time_out - time_in
    else
      0
    end
  end
  
  def unlink_from_payroll_entry
    self.payroll_entry.assignments_count -= 1
    self.payroll_entry.wage -= self.total
    self.payroll_entry.save
    
    self.payroll_entry_id = nil
    self.extras = 0
    self.save
  end
  
  def update_total
    self.total = self.job_wage + self.extras
  end
  
  def update_payroll_entry
    self.payroll_entry.wage += self.total - self.total_was
    self.payroll_entry.save
  end

  def format_money_amount_for_save(amount)
    amount.gsub(/[^\d\.]/, '')
  end
  
  def end_time_greater_than_start_time
    if self.time_out.present? and self.time_out <= self.time_in
      errors.add(:time_out, "must be later than time in")
    end
  end

  def set_wage_and_extras_properly
    if self.job_wage.present? && !is_numeric?(self.job_wage_before_type_cast)
      self.job_wage = format_money_amount_for_save self.job_wage_before_type_cast
    end

    if self.extras.present? && !is_numeric?(self.extras_before_type_cast)
      self.extras = format_money_amount_for_save self.extras_before_type_cast
    end

  end
  
end
