# == Schema Information
#
# Table name: credit_cards
#
#  id                 :integer          not null, primary key
#  customer_id        :integer
#  masked_card_number :string(255)
#  expiry_month       :integer
#  expiry_year        :integer
#  token              :text
#  card_type          :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'spec_helper'

describe CreditCard do
  pending "add some examples to (or delete) #{__FILE__}"
end
