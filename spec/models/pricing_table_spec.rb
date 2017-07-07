# == Schema Information
#
# Table name: pricing_tables
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  name             :string(255)
#  pricing_table    :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  custom_field_ids :text
#

require 'spec_helper'

describe PricingTable do
  pending "add some examples to (or delete) #{__FILE__}"
end
