# == Schema Information
#
# Table name: task_recurrences
#
#  id         :integer          not null, primary key
#  schedule   :text
#  user_id    :integer
#  task       :text
#  note       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe TaskRecurrence do
  pending "add some examples to (or delete) #{__FILE__}"
end
