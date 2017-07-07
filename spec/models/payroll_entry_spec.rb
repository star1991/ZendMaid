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

require 'spec_helper'

describe PayrollEntry do
  pending "add some examples to (or delete) #{__FILE__}"
end
