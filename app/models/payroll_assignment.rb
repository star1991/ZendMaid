# == Schema Information
#
# Table name: payroll_assignments
#
#  id                     :integer          not null, primary key
#  appointment_start_time :datetime
#  customer_name          :text
#  payroll_entry_id       :integer
#  time_in                :datetime
#  time_out               :datetime
#  job_wage               :decimal(8, 2)    default(0.0)
#  extras                 :decimal(8, 2)    default(0.0)
#  total                  :decimal(8, 2)    default(0.0)
#  appointment_revenue    :decimal(8, 2)    default(0.0)
#  pay_type               :string(255)
#  pay_rate               :decimal(8, 2)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class PayrollAssignment < ActiveRecord::Base
  attr_accessible :appointment_revenue, :appointment_start_time, :customer_name, :extras, :job_wage, :pay_rate, :pay_type, :payroll_entry_id, :time_in, :time_out, :total
  
  belongs_to :payroll_entry

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
 
end
