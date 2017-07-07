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

require 'spec_helper'

describe PayrollAssignment do
  pending "add some examples to (or delete) #{__FILE__}"
end
