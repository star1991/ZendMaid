# == Schema Information
#
# Table name: appointment_service_items
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  instruction_id :integer
#  value_name     :text
#  field_name     :string(255)
#

class AppointmentServiceItem < ActiveRecord::Base
  attr_accessible :field_name, :value_name, :instruction_id, :appointment_id
  
  belongs_to :appointment
  belongs_to :instruction

  
  validates_presence_of :instruction_id, :field_name
  
end
