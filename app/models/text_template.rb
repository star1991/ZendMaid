# == Schema Information
#
# Table name: text_templates
#
#  id            :integer          not null, primary key
#  body          :text
#  template_type :string(255)
#  user_id       :integer
#  time_offset   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  preferences   :text
#

class TextTemplate < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :body, :template_type, :time_offset, :user_id, :after_status
  serialize :preferences, Hash
  
  belongs_to :user
  
  validates_presence_of :template_type, :user_id
  
  has_many :template_jobs, :as => :sendable, :dependent => :destroy
  
  validate :text_template_under_length
  
  
  after_validation :record_liquid_parsing_errors
  
  def text_template_under_length
    if @body_syntax_error.nil?
      appointment = Appointment.limit(1).first
      drop = AppointmentDrop.new(appointment)
      
      rendered_text = liquidize(self.body, 'appointment' => drop)
      if rendered_text.length > 160
        errors.add(:body, "is too long (press the preview button to see an example)")
      end
    end
  end
  
  def record_liquid_parsing_errors
    errors.add :body, @body_syntax_error unless @body_syntax_error.nil?
  end
  
  def body=(text)
    self[:body] = text
    
    # check syntax
    begin 
      Liquid::Template.parse(text)
    rescue Liquid::SyntaxError => error
      @body_syntax_error = error.message
    end
  end

  def after_status
    self.preferences[:after_status]
  end
  
  def after_status=(status_id)
    self.preferences[:after_status] = status_id.to_i
  end

end
