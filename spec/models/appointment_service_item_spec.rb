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

require 'spec_helper'

describe AppointmentServiceItem do
  pending "add some examples to (or delete) #{__FILE__}"
end
