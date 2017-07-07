# == Schema Information
#
# Table name: tasks
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  task               :text
#  note               :text
#  due_date           :date
#  completed_on       :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  task_recurrence_id :integer
#

require 'spec_helper'

describe Task do
  pending "add some examples to (or delete) #{__FILE__}"
end
