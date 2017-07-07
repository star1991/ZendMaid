# == Schema Information
#
# Table name: instructions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  field_name :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Instruction do
  pending "add some examples to (or delete) #{__FILE__}"
end
