# == Schema Information
#
# Table name: appointment_items
#
#  id                   :integer          not null, primary key
#  appointment_id       :integer
#  appointment_field_id :integer
#  value_name           :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class AppointmentItem < ActiveRecord::Base
  attr_accessible :appointment_field_id, :appointment_id, :value_name
  
  belongs_to :appointment
  belongs_to :appointment_field
  
  validates_presence_of :appointment_field_id
  
  scope :items_in_preview, -> { includes(:appointment_field).where('appointment_fields.show_in_preview = ?', true) }
  
  validates_uniqueness_of :value_name, :if => Proc.new { |item| item.appointment_field.unique? && item.value_name.present? }
    
end
