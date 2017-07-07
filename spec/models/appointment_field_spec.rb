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

require 'spec_helper'

describe AppointmentField do
  pending "add some examples to (or delete) #{__FILE__}"
end
