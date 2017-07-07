class InstantBookingsMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  
  default from: "no-reply@zenmaid.com"
  
  helper :appointments
  helper :phone_number
  helper :application
  
  def view_instant_booking(instant_booking)
    @user = instant_booking.user
    email_template = @user.email_templates.find_by_template_type("Booking Confirmation")
    
    instant_booking_drop = InstantBookingDrop.new(instant_booking)
    title_template = Liquid::Template.parse(email_template.title)
    body_template = Liquid::Template.parse(email_template.body)
  
    @body = body_template.render('booking' => instant_booking_drop)
    mail(:to => "#{instant_booking.first_name} #{instant_booking.last_name} <#{instant_booking.email}>", :reply_to => @user.user_profile.company_email, :subject => title_template.render('booking' => instant_booking_drop))
  end
  
  def notify_client_of_booking(instant_booking)
    @user = instant_booking.user
    @instant_booking = instant_booking
    mail(:to => @user.user_profile.company_email, :subject => "[ZenMaid] Someone just booked an appointment with you at ZenMaid.com!")
  end
end
