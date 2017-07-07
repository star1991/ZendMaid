# == Schema Information
#
# Table name: instructions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  field_name :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Instruction < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :field_name, :order, :user_id
  
  belongs_to :user
  has_many :appointment_service_items, :dependent => :destroy
  
  validates_presence_of :field_name, :order
  
  default_scope :order => "instructions.order ASC"
end
