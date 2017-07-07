# == Schema Information
#
# Table name: emails
#
#  id             :integer          not null, primary key
#  address        :string(255)
#  email_type     :string(255)
#  primary        :boolean
#  send_automated :boolean          default(TRUE)
#  emailable_id   :integer
#  emailable_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Email do
  pending "add some examples to (or delete) #{__FILE__}"
end
