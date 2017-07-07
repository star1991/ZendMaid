# == Schema Information
#
# Table name: employees
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)
#  phone_number           :string(255)
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  notes                  :text
#  calendar_color         :string(255)      default("#026b9c")
#  encrypted_password     :string(128)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  allow_sign_in          :boolean          default(FALSE)
#  show_in_grid           :boolean          default(TRUE)
#  pay_type               :string(255)
#  pay_rate               :decimal(8, 2)
#  active                 :boolean          default(TRUE)
#  inactivated_on         :datetime
#  owner                  :boolean          default(FALSE)
#  assignable             :boolean          default(TRUE)
#  admin                  :boolean          default(FALSE)
#  allow_enter_time       :boolean          default(TRUE)
#

require 'spec_helper'

describe Employee do
  pending "add some examples to (or delete) #{__FILE__}"
end
