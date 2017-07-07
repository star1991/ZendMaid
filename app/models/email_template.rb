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

class EmailTemplate < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :active, :body, :title, :template_type, :user_id, :time_offset, :after_status, 
    :only_on_first, :template_resource, :mass_email, :send_to

  attr_accessor :send_to
  
  serialize :preferences, Hash
  
  belongs_to :user
  has_many :template_jobs, :as => :sendable, :dependent => :destroy
  
  validates_presence_of :template_type, :user_id, :template_resource, :title, :body
  
  validates_uniqueness_of :template_type, :scope => :user_id, :case_sensitive => false

  after_validation :record_liquid_parsing_errors
  
  def record_liquid_parsing_errors
    errors.add :title, @title_syntax_error unless @title_syntax_error.nil?
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
  
  def title=(text)
    self[:title] = text

    begin 
      Liquid::Template.parse(text)
    rescue Liquid::SyntaxError => error
      @title_syntax_error = error.message
    end
  end
  
  def after_status
    self.preferences[:after_status]
  end
  
  def after_status=(status_id)
    self.preferences[:after_status] = status_id.to_i
  end
  
  def only_on_first
    self.preferences[:only_on_first]
  end
  
  def only_on_first=(only)
    self.preferences[:only_on_first] = string_to_boolean only
  end

  def send_follow_up?(appointment, customer)
    appointment.status_id == self.preferences[:after_status] && (!self.preferences[:only_on_first] || customer.appointments.order("appointments.start_time ASC").limit(1).first.id == appointment.id)
  end
  
  def get_recipient_string
    case self.send_to
    when "All Contacts" 
      "#{self.user.customers.size} contacts"
    when "Leads Only"
      "#{self.user.customers.where(:lead => true).size} leads"
    when "Customers Only"
      "#{self.user.customers.where(:lead => false).size} customers"
    else
    end  
  end

end
