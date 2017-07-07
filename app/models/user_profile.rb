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

class UserProfile < ActiveRecord::Base
  include PhoneNumberHelper
  include ApplicationHelper

  attr_accessible :about_us, :company_email, :company_name, :company_phone_number, :user_id, :logo, :facebook_page, 
  :website, :why_sign_up, :current_management, :specific_features, :struggles, :entrance_survey, :full_name, :exit_survey,
  :why_leaving, :previous_system, :intented_new_system, :required_specific_feature, :recommendation, :other_feedback, 
  :where_hear_about_us

  attr_accessor :entrance_survey, :full_name, :exit_survey
  
  mount_uploader :logo, LogoUploader
  
  belongs_to :user
  
  before_validation do |user_profile|
    user_profile.company_phone_number = strip_nondigits_from_phone_number company_phone_number
  end
  
  before_save do |user_profile|
    user_profile.company_email = company_email.downcase
  end
  
  validates :company_email, :presence => true, :format=> { :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, :message => "is not a valid email address" },
                    :uniqueness => { :case_sensitive => false }
  validates :user_id, :presence => true
  
  validates :company_phone_number, :length => {:minimum => 10, :maximum => 11, :message => " must be a valid phone number with area code"}, :unless => Proc.new { |u| u.new_record? }
  validates :company_name, :presence => true, :unless => Proc.new { |u| u.new_record? }
  validates :where_hear_about_us, :presence => true, :if  => Proc.new { |u| string_to_boolean(u.entrance_survey) }
  validates :why_sign_up, :presence => true, :if  => Proc.new { |u| string_to_boolean(u.entrance_survey) }
  validates :current_management, :presence => true, :if => Proc.new { |u| string_to_boolean(u.entrance_survey) }

  validates :why_leaving, :presence => true, :if  => Proc.new { |u| string_to_boolean(u.exit_survey) }
  validates :previous_system, :presence => true, :if => Proc.new { |u| string_to_boolean(u.exit_survey) }
  validates :required_specific_feature, :presence => true, :if => Proc.new { |u| string_to_boolean(u.exit_survey) }
  validates_numericality_of :recommendation, :only_integer => true, :if => Proc.new { |u| string_to_boolean(u.exit_survey) }
end
