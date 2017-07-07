# == Schema Information
#
# Table name: payment_gateways
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  gateway_name   :string(255)      default("Stripe")
#  stripe_api_key :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe PaymentGateway do
  pending "add some examples to (or delete) #{__FILE__}"
end
