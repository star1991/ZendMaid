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

class Auth < ActiveRecord::Base
  attr_accessible :oauth_token, :oauth_secret, :provider, :dc, :list_id, :name, :provider_id

  belongs_to :user, :inverse_of => :auth
end
