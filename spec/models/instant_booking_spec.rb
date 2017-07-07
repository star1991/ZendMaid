# == Schema Information
#
# Table name: instant_bookings
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  phone_number    :string(255)
#  email           :string(255)
#  start_time      :datetime
#  price           :decimal(8, 2)
#  service_type_id :integer
#  requests        :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pending         :boolean          default(TRUE)
#  appointment_id  :integer
#

require 'spec_helper'

describe InstantBooking do
  pending "add some examples to (or delete) #{__FILE__}"
end
