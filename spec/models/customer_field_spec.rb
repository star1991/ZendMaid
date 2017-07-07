# == Schema Information
#
# Table name: customer_fields
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  field_name      :string(255)
#  input_type      :string(255)
#  value_names     :text
#  order           :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  min_field_value :integer          default(1)
#  max_field_value :integer
#

require 'spec_helper'

describe CustomerField do
  pending "add some examples to (or delete) #{__FILE__}"
end
