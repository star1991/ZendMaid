# == Schema Information
#
# Table name: payrolls
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  payroll_number        :integer
#  start_date            :datetime
#  end_date              :datetime
#  draft                 :boolean          default(TRUE)
#  total_pay             :decimal(8, 2)    default(0.0)
#  appointments_count    :integer          default(0)
#  payroll_entries_count :integer          default(0)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  out_of_date           :boolean          default(FALSE)
#

class Payroll < ActiveRecord::Base
  attr_accessible :draft, :end_date, :extras, :start_date, :total_pay, :total_reg_pay

  has_many :appointments, :dependent => :nullify
  has_many :payroll_entries, :dependent => :destroy
  has_many :assignments, :through => :payroll_entries
  has_many :payroll_assignments, :through => :payroll_entries

  belongs_to :user
  before_create :populate_payroll_number
  
  def populate_payroll_number
    self.user.increment!(:last_used_payroll_number)
    self.payroll_number = self.user.last_used_payroll_number
  end

  def populate_draft_payroll
    employees_with_appointments = self.user.employees.active.includes({:assignments => {:appointment => :status}}).where("appointments.use_as_prototype = ?", false).where('statuses.use_for_payroll = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", self.end_date, self.start_date).where('appointments.payroll_id IS ?', nil)
    
    if employees_with_appointments.blank?
      return false
    end
    
    # Perhaps can be made faster using smart caching and DB queries
    # We will see how this scales to > 1000 appointments at a time
    appointment_ids = []
    self.total_pay = 0
    employees_with_appointments.each do |employee|
      payroll_entry = self.payroll_entries.build(:employee_id => employee.id, :pay_type => employee.pay_type, :pay_rate => employee.pay_rate, :full_name => employee.full_name)
      
      employee.assignments.each do |assignment|
        payroll_entry.assignments << assignment
      end
      
      payroll_entry.assignments_count = employee.assignments.size
      employee_pay = payroll_entry.calculate_wage
      
      appointment_ids += employee.assignments.map(&:appointment_id)
      self.total_pay += employee_pay
    end
    
    appointment_ids.uniq!
    self.appointments_count = appointment_ids.size
    self.payroll_entries_count = self.payroll_entries.size
    
    self.save
    
    self.user.appointments.where('appointments.id in (?)', appointment_ids).update_all(:payroll_id => self.id)
  end

  def approve!
    self.draft = false
    
    self.payroll_entries.each do |entry|
      entry.approve!
    end

    self.save
  end

end
