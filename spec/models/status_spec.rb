# == Schema Information
#
# Table name: statuses
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  user_id             :integer
#  order               :integer
#  calendar_color      :string(255)      default("#026b9c")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  show_by_default     :boolean          default(TRUE)
#  use_for_conflicts   :boolean          default(TRUE)
#  show_in_work_orders :boolean          default(TRUE)
#  use_for_payroll     :boolean          default(TRUE)
#  use_for_invoice     :boolean
#

require 'spec_helper'

describe Status do
  pending "add some examples to (or delete) #{__FILE__}"
end
