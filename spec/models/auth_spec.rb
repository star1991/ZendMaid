# == Schema Information
#
# Table name: auths
#
#  id           :integer          not null, primary key
#  oauth_token  :string(255)
#  oauth_secret :string(255)
#  user_id      :integer
#  provider     :string(255)
#  dc           :string(255)
#  list_id      :string(255)
#  name         :string(255)
#  provider_id  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Auth do
  pending "add some examples to (or delete) #{__FILE__}"
end
