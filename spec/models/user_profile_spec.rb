# == Schema Information
#
# Table name: user_profiles
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  company_email             :string(255)
#  company_phone_number      :string(255)
#  company_name              :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  logo                      :string(255)
#  website                   :text
#  facebook_page             :text
#  why_sign_up               :text
#  current_management        :text
#  specific_features         :text
#  struggles                 :text
#  why_leaving               :text
#  previous_system           :text
#  intented_new_system       :text
#  required_specific_feature :text
#  recommendation            :integer
#  other_feedback            :text
#  where_hear_about_us       :text
#

require 'spec_helper'

describe UserProfile do
  pending "add some examples to (or delete) #{__FILE__}"
end
