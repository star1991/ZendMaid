# == Schema Information
#
# Table name: template_jobs
#
#  id              :integer          not null, primary key
#  scheduled_on    :datetime
#  sent_on         :datetime
#  sendable_id     :integer
#  sendable_type   :string(255)
#  reportable_id   :integer
#  reportable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe TemplateJob do
  pending "add some examples to (or delete) #{__FILE__}"
end
