# == Schema Information
#
# Table name: log_entries
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  log_type       :string(255)
#  entry          :text
#  note           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe LogEntry do
  pending "add some examples to (or delete) #{__FILE__}"
end
