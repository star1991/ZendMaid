# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  start_time            :datetime         not null
#  end_time              :datetime         not null
#  active                :boolean          default(TRUE)
#  interval              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  frequency             :integer
#  materialized_until    :datetime
#  constraints           :text
#  repeat_on             :text
#  subscriptionable_id   :integer
#  subscriptionable_type :string(255)
#  parent_id             :integer
#  title                 :string(255)
#

require 'spec_helper'

describe Subscription do
  pending "add some examples to (or delete) #{__FILE__}"
end
