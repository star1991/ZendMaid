# == Schema Information
#
# Table name: log_entries
#
#  id             :integer          not null, primary key
#  appointment_id :integer
#  log_type       :string(255)
#  entry          :text
#  note           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class LogEntry < ActiveRecord::Base
  attr_accessible :appointment_id, :entry, :note, :log_type
  
  validates_presence_of :appointment_id, :entry, :log_type
  
  default_scope :order => "log_entries.created_at DESC"
  
  belongs_to :appointment
end
