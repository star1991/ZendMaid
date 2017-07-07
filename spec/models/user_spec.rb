# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  email                     :string(255)      default(""), not null
#  encrypted_password        :string(255)      default(""), not null
#  reset_password_token      :string(255)
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0)
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :string(255)
#  last_sign_in_ip           :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  phone_number              :string(255)
#  plan_id                   :string(255)
#  stripe_customer_token     :string(255)
#  preferences               :text
#  marketing_plan            :boolean          default(FALSE)
#  company_name              :string(255)
#  last_used_payroll_number  :integer          default(0)
#  active                    :boolean          default(TRUE)
#  completed_onboarding      :boolean          default(FALSE)
#  onboarding_page           :integer          default(1)
#  allow_employee_sign_in    :boolean          default(FALSE)
#  default_employee_password :string(255)
#  default_pay_type          :string(255)
#  default_pay_rate          :decimal(8, 2)
#  free_trial_end            :datetime
#  allow_cc_processing       :boolean          default(FALSE)
#  booking_form_started      :boolean          default(FALSE)
#  qb_access_token           :string(255)
#  qb_access_secret          :string(255)
#  qb_company_id             :string(255)
#  qb_token_expires_at       :datetime
#  qb_reconnect_token_at     :datetime
#  qb_syncing                :boolean          default(FALSE)
#  qb_last_sync              :datetime
#  converted_at              :datetime
#  mailchimp_last_sync       :datetime
#  mailchimp_syncing         :boolean          default(FALSE)
#

require 'spec_helper'

describe User do
  pending "add some examples to (or delete) #{__FILE__}"
end
