# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  line1            :string(255)
#  line2            :string(255)
#  city             :string(255)
#  state            :string(2)
#  postal_code      :string(255)
#  addressable_id   :integer
#  addressable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  billing          :boolean          default(FALSE)
#

require 'spec_helper'

describe Address do
  pending "add some examples to (or delete) #{__FILE__}"
end
