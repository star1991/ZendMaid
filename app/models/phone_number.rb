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

class PhoneNumber < ActiveRecord::Base
  include PhoneNumberHelper
  
  attr_accessible :phone_number, :phone_number_type, :primary

  validates_presence_of :phone_number
  belongs_to :phone_numberable, :polymorphic => true

  before_validation do |ph|
    ph.phone_number = phone_number.present? ? strip_nondigits_from_phone_number(phone_number) : nil
  end
  
  validates :phone_number, :length => {:minimum => 10, :maximum => 11, :message => " must be a valid US phone number with area code"}
  
  
end
