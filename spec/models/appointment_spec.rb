# == Schema Information
#
# Table name: appointments
#
#  id                :integer          not null, primary key
#  subscription_id   :integer
#  start_time        :datetime
#  end_time          :datetime
#  paid              :boolean          default(FALSE)
#  cancelled         :boolean          default(FALSE)
#  assigned          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  requests          :text
#  confirmed         :boolean          default(FALSE)
#  price             :decimal(8, 2)
#  notes             :text
#  service_type_id   :integer
#  use_as_prototype  :boolean          default(FALSE)
#  status_id         :integer
#  assignments_count :integer          default(0)
#  team_id           :integer
#  sent_on           :text
#  payroll_id        :integer
#

require 'spec_helper'

describe Appointment do
  pending "add some examples to (or delete) #{__FILE__}"
end
