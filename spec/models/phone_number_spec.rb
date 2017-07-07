# == Schema Information
#
# Table name: phone_numbers
#
#  id                    :integer          not null, primary key
#  phone_number          :string(255)
#  phone_number_type     :string(255)
#  primary               :boolean          default(FALSE)
#  phone_numberable_id   :integer
#  phone_numberable_type :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe PhoneNumber do
  pending "add some examples to (or delete) #{__FILE__}"
end
