# == Schema Information
#
# Table name: payroll_entries
#
#  id                :integer          not null, primary key
#  employee_id       :integer
#  payroll_id        :integer
#  wage              :decimal(8, 2)    default(0.0)
#  bonus             :decimal(8, 2)    default(0.0)
#  deductions        :decimal(8, 2)    default(0.0)
#  total_pay         :decimal(8, 2)    default(0.0)
#  assignments_count :integer          default(0)
#  pay_type          :string(255)
#  pay_rate          :decimal(8, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  draft             :boolean          default(TRUE)
#  full_name         :string(255)
#

class PayrollEntry < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  attr_accessible :bonus, :deductions, :earnings, :employee_id, :pay_rate, :payroll_id, :total_pay, :pay_type, :full_name
  
  #Calculated on he fly for reporting purposes
  attr_accessor :total_job_wage, :total_duration, :total_revenue, :total_extras
  
  belongs_to :payroll
  belongs_to :employee
  
  has_one :user, :through => :payroll
  has_many :assignments, :autosave => true, :dependent => :nullify
  has_many :payroll_assignments, :dependent => :destroy
  
  before_update :calculate_wage, :if => Proc.new { |entry| entry.pay_type_changed? || entry.pay_rate_changed? }
  before_save :set_total_pay
  
  before_destroy :remove_from_payroll_total
  after_update :adjust_payroll_total
  
  validate :bonus_range
  validate :deductions_range
  
  def remove_from_payroll_total
    self.payroll.total_pay -= self.total_pay
    self.payroll.payroll_entries_count -= 1
    self.payroll.save
  end
  
  def calculate_wage
    self.wage = 0
    self.assignments.each do |assignment|
      assignment.pay_type = self.pay_type
      assignment.pay_rate = self.pay_rate
      # Note: set_job_wage returns wage + extras on each assignment (i.e., assignment.total column)
      self.wage += assignment.set_job_wage
    end
    
    # because before_save runs before before_update
    self.set_total_pay
    return self.wage
  end
  
  def adjust_payroll_total
    self.payroll.total_pay += (self.total_pay - self.total_pay_was)
    self.payroll.save
  end
  
  def set_total_pay
    self.total_pay = self.wage + self.bonus - self.deductions
  end
  
  # Do this because numericality validation for some reason considers the value before typecast (decimal field strips out all non-digits automatically)
  def bonus_range
    if self.bonus.blank?
      errors.add(:bonus, "can't be blank")
    elsif self.bonus < 0
      errors.add(:bonus, "must be greater than zero")
    elsif self.bonus >= 1000000
      errors.add(:bonus, "must be less than 1000000")
    end
  end

  def deductions_range
    if self.deductions.blank?
      errors.add(:deductions, "can't be blank")
    elsif self.deductions < 0
      errors.add(:deductions, "must be greater than zero")
    elsif self.deductions >= 1000000
      errors.add(:deductions, "must be less than 1000000")
    end
  end
  
  def group_by_date_and_calculate_totals
    entries_by_date = Hash.new([])
    
    self.total_duration = 0
    self.total_extras = 0
    self.total_job_wage = 0
    self.total_revenue = 0
    
    assignments = self.assignments.includes({:appointment => [:service_type, :customer]}).order('appointments.start_time ASC')
    assignments.each do |assignment|
      entries_by_date[assignment.appointment.start_time.strftime('%-m/%-d/%Y')] += [assignment]
      
      self.total_extras += assignment.extras
      self.total_job_wage += assignment.job_wage
      self.total_duration += assignment.duration
      
      if assignment.appointment.price.present?
        self.total_revenue += assignment.appointment.price
      end
    end
    
    return entries_by_date    
  end

  def calculate_totals_for_report
    
    self.total_duration = 0
    self.total_extras = 0
    self.total_job_wage = 0
    self.total_revenue = 0
     
    self.payroll_assignments.each do |assignment|
      
      self.total_extras += assignment.extras
      self.total_job_wage += assignment.job_wage
      self.total_duration += assignment.duration
      self.total_revenue += assignment.appointment_revenue || 0
    end   
  end
  
  def approve!
    self.draft = false
    
    self.assignments.includes(:appointment => :customer).each do |assignment|
      self.payroll_assignments.build(
        :appointment_revenue => assignment.appointment.price,
        :appointment_start_time => assignment.appointment.start_time,
        :customer_name => assignment.appointment.customer.full_name,
        :extras => assignment.extras,
        :job_wage => assignment.job_wage, 
        :pay_rate => assignment.pay_rate,
        :pay_type => assignment.pay_type,
        :time_in => assignment.time_in,
        :time_out => assignment.time_out,
        :total => assignment.total
      )
    end
    
    self.save
    self.assignments.update_all(:payroll_entry_id => nil)
  end

end
