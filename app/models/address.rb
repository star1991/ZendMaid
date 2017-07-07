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

class Address < ActiveRecord::Base
  attr_accessible :city, :line1, :line2, :state, :postal_code, :from_instant_booking, :billing
  attr_accessor :from_instant_booking

  belongs_to :addressable, :polymorphic => true

  validates :line1, :presence => true
  validates :state, :length => { :is => 2 }, :allow_blank => true

  validates_presence_of :city, :state, :postal_code, :if => :from_instant_booking

  def full_address
    "#{line1} #{city} #{state}"
  end
end
