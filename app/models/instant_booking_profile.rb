# == Schema Information
#
# Table name: instant_booking_profiles
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subdomain                  :string(255)
#  advance_booking_days       :integer          default(1)
#  default_appointment_length :integer          default(3)
#  embed                      :boolean          default(FALSE)
#  custom_css                 :text
#  about_us                   :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  show_price                 :boolean          default(TRUE)
#  show_about_us              :boolean          default(TRUE)
#  compact                    :boolean          default(FALSE)
#  font_urls                  :text
#  button_color_class         :string(255)
#  call_to_action             :string(255)      default("Book your Cleaning Instantly in 3 Easy Steps")
#  time_options               :text
#  skip_days                  :text
#

class InstantBookingProfile < ActiveRecord::Base
  attr_accessible :user_id, :about_us, :subdomain, :embed, :custom_css, :font_urls, :button_color_class, :compact, :show_price, :show_about_us, :call_to_action
  
  belongs_to :user
  serialize :font_urls, Array
  serialize :skip_days, Array
  serialize :time_options, Array  
  
  validates :subdomain, :uniqueness => {:case_sensitive => false, :allow_nil => true}

  after_initialize :set_skip_days  
  after_initialize :set_time_options


  before_save do |profile|
    if profile.subdomain.present?
     profile.subdomain = subdomain.downcase
    end
  end

  def set_time_options
    if self.time_options.size == 0
      self.time_options = [
        ['Morning (9 AM - 11 AM)', '9:00 AM'],
        ['Midday (11 AM - 1 PM)', '11:00 AM'],
        ['Early Afternoon (1 PM - 3 PM)', '1:00 PM'],
        ['Late Afternoon (3 PM - 5PM)', '3:00 PM']
      ]
    end   
  end

  def set_skip_days
    self.skip_days ||= []
  end

end