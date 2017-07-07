# == Schema Information
#
# Table name: teams
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  name           :string(255)
#  calendar_color :string(255)      default("#026b9c")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Team do
  pending "add some examples to (or delete) #{__FILE__}"
end
