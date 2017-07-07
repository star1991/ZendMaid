# == Schema Information
#
# Table name: email_templates
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  title             :text
#  body              :text
#  template_type     :string(255)
#  active            :boolean          default(TRUE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  time_offset       :integer
#  preferences       :text
#  template_resource :string(255)      default("Appointment")
#  marketing_plan    :boolean          default(FALSE)
#  mass_email        :boolean          default(FALSE)
#

require 'spec_helper'

describe EmailTemplate do
  pending "add some examples to (or delete) #{__FILE__}"
end
