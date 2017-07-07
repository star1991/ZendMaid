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

class PaymentGateway < ActiveRecord::Base

  belongs_to :user, :inverse_of => :payment_gateway

  attr_accessible :gateway_name, :stripe_api_key, :user_id

  validates_presence_of :stripe_api_key, :if => Proc.new { |pg| pg.gateway_name == "Stripe" && pg.user.allow_cc_processing? }
end
