# == Schema Information
#
# Table name: appointment_fields
#
#  id               :integer          not null, primary key
#  field_name       :string(255)
#  input_type       :string(255)
#  price            :decimal(8, 2)
#  max_field_value  :integer
#  min_field_value  :integer          default(1)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order            :integer          default(1), not null
#  active           :boolean          default(TRUE)
#  extra            :boolean          default(TRUE)
#  value_names      :text
#  pricing_table_id :integer
#  display_label    :boolean          default(TRUE)
#  service_type_id  :integer
#  show_in_table    :boolean          default(FALSE)
#  user_id          :integer
#  unique           :boolean          default(FALSE)
#  show_in_preview  :boolean          default(FALSE)
#

class AppointmentField < ActiveRecord::Base
  attr_accessible :field_name, :input_type, :max_field_value, :min_field_value, :price, :user_id, :order, :user_id, 
    :show_in_table, :show_in_preview, :pricing_table_id, :value_names, :service_type_id
  
  serialize :value_names, Hash
  
  belongs_to :service_type
  belongs_to :user
  belongs_to :pricing_table
  has_many :appointment_items, :dependent => :destroy
  
  validates_presence_of :field_name, :input_type, :order, :user_id
  
  default_scope :order => "appointment_fields.order ASC"
  scope :by_service_type, lambda { |service_type| where('service_type_id = ?', service_type.id) }
  scope :for_table, where(:show_in_table => true)
  scope :for_event_preview, where(:show_in_preview => true)
  
  
  before_save do |appointment_field|
    if appointment_field.value_names.blank? and appointment_field.input_type.present?
      appointment_field.value_names = self.generate_default_value_names
    end
  end
  
  
  
  # Sets default value names to Yes and No for boolean and string typecast of integers for selects and radios
  def generate_default_value_names()
    if self.input_type == 'select'
      default_value_names = Hash[(self.min_field_value..self.max_field_value).map { |i| [i, i.to_s] }]
      default_value_names[self.max_field_value] += '+'
    elsif self.input_type == 'boolean'
      default_value_names = {0 => 'No', 1 => 'Yes'}
    end

    default_value_names
  end
 
  
end
