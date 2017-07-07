# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  active             :boolean          default(TRUE)
#  company_name       :string(255)
#  title              :string(255)
#  sent_on            :text
#  notes              :text
#  balance            :decimal(10, 2)   default(0.0)
#  revenue            :decimal(10, 2)   default(0.0)
#  stripe_customer_id :string(255)
#  lead               :boolean          default(TRUE)
#  qb_customer_id     :integer
#  imported           :boolean          default(FALSE)
#  marketing_source   :string(255)
#

require 'spec_helper'

describe Customer do
  pending "add some examples to (or delete) #{__FILE__}"
end
