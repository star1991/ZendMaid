# == Schema Information
#
# Table name: leads
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  email                 :string(255)
#  phone_number          :string(255)
#  company_name          :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  stripe_customer_token :string(255)
#  plan_id               :string(255)
#

require 'spec_helper'

describe Lead do
  pending "add some examples to (or delete) #{__FILE__}"
end
