# == Schema Information
#
# Table name: service_types
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  base_price      :decimal(8, 2)    default(0.0)
#  show_in_booking :boolean          default(TRUE)
#

class ServiceType < ActiveRecord::Base
  attr_accessible :name, :base_price, :show_in_booking
  
  validates_presence_of :base_price, :name
  
  has_many :instant_booking_fields, :class_name => "CustomField", :conditions => {:field_type => 'instant_booking'}, :dependent => :destroy
  
  scope :bookable, ->{ where("service_types.show_in_booking = ?", true)}
  
  has_many :appointments
  has_many :instant_bookings
  belongs_to :user
  
end
