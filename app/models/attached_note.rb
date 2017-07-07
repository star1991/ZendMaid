# == Schema Information
#
# Table name: attached_notes
#
#  id            :integer          not null, primary key
#  body          :text
#  noteable_id   :integer
#  noteable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class AttachedNote < ActiveRecord::Base
  attr_accessible :body, :noteable_id, :noteable_type
  
  belongs_to :noteable, :polymorphic => true
  
  validates_presence_of :body
  
end
