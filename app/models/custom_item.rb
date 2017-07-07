# == Schema Information
#
# Table name: custom_items
#
#  id                :integer          not null, primary key
#  customizable_id   :integer
#  custom_field_id   :integer
#  value_name        :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  customizable_type :string(255)
#

class CustomItem < ActiveRecord::Base
  attr_accessible :custom_field_id, :customizable_id, :value_name
  
  belongs_to :customizable, :polymorphic => true
  belongs_to :custom_field
  
  validates_presence_of :custom_field_id

  scope :visible, joins(:custom_field).where("custom_fields.hide_from_employees = ?", false)

  # validates_uniqueness_of :value_name, :if => Proc.new { |item| item.custom_field.unique? && item.value_name.present? }


end
