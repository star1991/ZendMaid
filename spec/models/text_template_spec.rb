# == Schema Information
#
# Table name: text_templates
#
#  id            :integer          not null, primary key
#  body          :text
#  template_type :string(255)
#  user_id       :integer
#  time_offset   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  preferences   :text
#

require 'spec_helper'

describe TextTemplate do
  pending "add some examples to (or delete) #{__FILE__}"
end
