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

require 'spec_helper'

describe AppointmentItem do
  pending "add some examples to (or delete) #{__FILE__}"
end
