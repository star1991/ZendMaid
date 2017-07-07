# == Schema Information
#
# Table name: customer_items
#
#  id                :integer          not null, primary key
#  customer_id       :integer
#  customer_field_id :integer
#  value_name        :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe CustomerItem do
  pending "add some examples to (or delete) #{__FILE__}"
end
