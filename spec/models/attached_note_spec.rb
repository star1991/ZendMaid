# == Schema Information
#
# Table name: attached_notes
#
#  id            :integer          not null, primary key
#  body          :text
#  noteable_id   :integer
#  noteable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe AttachedNote do
  pending "add some examples to (or delete) #{__FILE__}"
end
