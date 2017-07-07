# == Schema Information
#
# Table name: instant_bookings
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  phone_number    :string(255)
#  email           :string(255)
#  start_time      :datetime
#  price           :decimal(8, 2)
#  service_type_id :integer
#  requests        :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pending         :boolean          default(TRUE)
#  appointment_id  :integer
#

class InstantBooking < ActiveRecord::Base
  include ApplicationHelper
  include PhoneNumberHelper
  include ActionView::Helpers::TextHelper  

 
  attr_accessible :email, :first_name, :last_name, :phone_number, :requests, :service_type_id, :start_time, :price, :address_attributes, :instant_booking_items_attributes, 
    :start_time_date, :start_time_time, :nested_validation_user_id, :pending, :appointment_id
  attr_accessor :start_time_time, :start_time_date, :nested_validation_user_id
  
  belongs_to :service_type
  belongs_to :appointment
  has_one :user, :through => :service_type
  
  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :instant_booking_items, :as => :customizable, :class_name => "CustomItem", :dependent => :destroy
  
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :instant_booking_items, :allow_destroy => true
  
  validates_presence_of :start_time, :start_time_time, :start_time_date
  validates_presence_of :email, :phone_number, :first_name, :last_name, :service_type_id
  validates :phone_number, :length => {:minimum => 10, :maximum => 11, :message => " must be a valid US phone number with area code"}
  validates :email, :format=> { :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  
  validate :instant_booking_sufficiently_in_advance
  validates :price, :format => { :with => /^\d+??(?:\.\d{0,2})?$/, :message => "must be a valid US Dollar Amount (e.g., $1.00 or $1)"}, :numericality => {:greater_than_or_equal_to => 0}, :allow_blank => true
  
  scope :pending, where(:pending => true)
  
  before_validation do |booking|
    if price.present? && !is_numeric?(price_before_type_cast)
      booking.price = format_price_for_save price_before_type_cast
    end

    if booking.start_time_date.present? && booking.start_time_time.present?
      booking.start_time = Time.zone.parse("#{booking.start_time_date} #{booking.start_time_time}")
    end
    
    booking.phone_number = phone_number.present? ? strip_nondigits_from_phone_number(phone_number) : nil
    booking.first_name = first_name.try(:capitalize)
    booking.last_name = last_name.try(:capitalize)  
    booking.email = email.present? ? email.downcase : nil
    
  end

  def instant_booking_sufficiently_in_advance
    user = User.find_by_id(self.nested_validation_user_id)
    if user.present? && self.start_time.present? && user.instant_booking_profile.advance_booking_days.days.from_now.beginning_of_day > self.start_time.beginning_of_day
      errors[:start_time_date] << "Appointments must be booked at least #{pluralize(user.instant_booking_profile.advance_booking_days, 'days')} in advance"
    end
  end

  def format_price_for_save(price)
    price.gsub(/[^\d\.]/, '')
  end

  def start_time_time
    @start_time_time || start_time.try(:strftime, '%l:%M %p')
  end
  
  def start_time_date
    @start_time_date || start_time.try(:strftime, '%d/%m/%Y')
  end

  def build_all_missing_instant_booking_items(user)
   (user.instant_booking_fields.map(&:id) - self.instant_booking_items.map(&:custom_field_id)).each do |id|
      self.instant_booking_items.build(:custom_field_id => id)
    end
  end
  
  def full_name
    [self.first_name, self.last_name].join(' ')
  end

end
