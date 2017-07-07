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

require 'spec_helper'

describe Payroll do
  pending "add some examples to (or delete) #{__FILE__}"
end
