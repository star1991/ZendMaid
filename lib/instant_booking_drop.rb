class InstantBookingDrop < Liquid::Drop
  include ApplicationHelper
  include PhoneNumberHelper
  include AppointmentsHelper

  def initialize(instant_booking)
    @instant_booking = instant_booking
  end
  
  def phone_number
    formatted_phone_number @instant_booking.phone_number
  end
  
  def address
    address = @instant_booking.address
    "#{address.line1}, #{address.city}, #{address.state} #{address.postal_code}"
  end
  
  def address_alt
    address = @instant_booking.address
    "#{address.line1}<br>#{address.city}, #{address.state} #{address.postal_code}"
  end
  
  def email
    @instant_booking.email
  end
  
  def full_name
    "#{@instant_booking.first_name} #{@instant_booking.last_name}"
  end
  
  def first_name
    @instant_booking.first_name
  end
  
  def start_time_approximate
    formatted_time(@instant_booking.start_time, :exact => false)
  end
  
  def start_date
    @instant_booking.start_time.strftime('%-m/%-d/%Y')
  end

  def estimate
    number_to_currency(@instant_booking.price)
  end

  def service_type
    @instant_booking.service_type.present? ? @instant_booking.service_type.name : "Cleaning"
  end
  
  def my_company_name
    @instant_booking.user.user_profile.company_name
  end
  
  def my_company_email
    @instant_booking.user.user_profile.company_email
  end
  
  def my_company_phone_number
    formatted_phone_number @instant_booking.user.user_profile.company_phone_number
  end

  def website
    if @instant_booking.user.user_profile.try(:website).present?
      "<a href=\"#{smart_add_url_protocol @instant_booking.user.user_profile.website}\">#{@instant_booking.user.user_profile.website}</a>"
    end
  end
  
  def facebook
    if @instant_booking.user.user_profile.try(:facebook_page).present?
      "<a href=\"#{smart_add_url_protocol @instant_booking.user.user_profile.facebook_page}\">Like us on Facebook!</a>"
    end
  end
    
end