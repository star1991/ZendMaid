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

class PricingTable < ActiveRecord::Base
  attr_accessible :name, :pricing_table, :user_id
  
  serialize :pricing_table, Hash
  serialize :custom_field_ids, Array  

  belongs_to :user
end
