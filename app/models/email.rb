# == Schema Information
#
# Table name: emails
#
#  id             :integer          not null, primary key
#  address        :string(255)
#  email_type     :string(255)
#  primary        :boolean
#  send_automated :boolean          default(TRUE)
#  emailable_id   :integer
#  emailable_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Email < ActiveRecord::Base
  attr_accessible :address, :email_type, :primary, :send_automated
  
  belongs_to :emailable, :polymorphic => true

  validates_presence_of :address  
  validates :address, :format=> { :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  before_validation do |email| 
    email.address = address.present? ? address.downcase : nil
  end
 
end
