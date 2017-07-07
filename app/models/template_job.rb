# == Schema Information
#
# Table name: template_jobs
#
#  id              :integer          not null, primary key
#  scheduled_on    :datetime
#  sent_on         :datetime
#  sendable_id     :integer
#  sendable_type   :string(255)
#  reportable_id   :integer
#  reportable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TemplateJob < ActiveRecord::Base
  attr_accessible :scheduled_on, :sent_on, :sendable_id, :sendable_type, :reportable_id, :reportable_type
  
  belongs_to :sendable, :polymorphic => true
  belongs_to :reportable, :polymorphic => true
  
  
  def update_time
    logger.debug self.attributes.inspect
    if self.allowed_to_send?
      self.scheduled_on = self.reportable.start_time + self.sendable.time_offset
    end
  end
  
  def allowed_to_send?
    extra_bool = true
    
    if self.sendable.template_type == "Appointment Follow-Up" && self.reportable.status_id != self.sendable.preferences[:after_status]
      extra_bool = false
    end
    
    self.sendable.time_offset.present? && extra_bool
  end
end
