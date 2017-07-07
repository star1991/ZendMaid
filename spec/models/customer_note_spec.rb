# == Schema Information
#
# Table name: customer_notes
#
#  id          :integer          not null, primary key
#  body        :text
#  customer_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe CustomerNote do
  pending "add some examples to (or delete) #{__FILE__}"
end
