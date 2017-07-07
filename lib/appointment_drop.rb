class AppointmentDrop < Liquid::Drop
  include ApplicationHelper
  include PhoneNumberHelper
  include AppointmentsHelper
  include SubscriptionsHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  
  def initialize(appointment)
    @appointment = appointment
  end
  
  def start_time_approximate
    formatted_time(@appointment.start_time, :exact => false)
  end
  
  def start_time_approx_one
    "#{@appointment.start_time.strftime('%-l %p')} - #{(@appointment.start_time + 1.hour).strftime('%-l %p')}"
  end

  def start_time_approx_two
    "#{@appointment.start_time.strftime('%-l %p')} - #{(@appointment.start_time + 2.hours).strftime('%-l %p')}"
  end
  
  def start_time
    formatted_time(@appointment.start_time, :exact => true)
  end

  def am_pm
    @appointment.start_time.hour < 12 ? "morning" : "afternoon"
  end
  
  def end_time
    formatted_time(@appointment.end_time, :exact => true)
  end
  
  def start_date_in_words
    @appointment.start_time.strftime('%A, %b %-d')
  end
  
  def start_date
    @appointment.start_time.strftime('%-m/%-d/%Y')
  end
  
  def customer_phone_number
    formatted_phone_number @appointment.customer.phone_numbers.first.try(:phone_number)
  end
  
  def address
    address = @appointment.address
    "#{address.line1}, #{address.city}, #{address.state} #{address.postal_code}"
  end
  
  def address_alt
    address = @appointment.address
    "#{address.line1}<br> #{address.city}, #{address.state} #{address.postal_code}"
  end
  
  def assigned_cleaners
    "#{@appointment.team.present? ? "<i>#{@appointment.team.name}</i><br>" : ""}#{@appointment.employees.map { |e| e.full_name }.join("<br>")}"
  end
  
  def notes
    simple_format_no_tags(@appointment.notes)
  end

  def customer_notes
    simple_format_no_tags(@appointment.customer.notes)
  end
  
  def appointment_custom_fields
    # Note, the visible scope includes a join on the custom field
    @appointment.appointment_items.visible.order("custom_fields.order ASC").map { |item| "<b>#{item.custom_field.field_name}</b> #{item.value_name}" }.join("<br>")
  end

  def customer_custom_fields
    # Note, the visible scope includes a join on the custom field
    @appointment.customer.customer_items.visible.order("custom_fields.order ASC").map { |item| "<b>#{item.custom_field.field_name}</b> #{item.value_name}" }.join("<br>")
  end
  
  def customer_contact_emails
    @appointment.customer.emails.map { |email| email.address }.join('<br>')
  end
  
  def customer_contact_phone_numbers
    @appointment.customer.phone_numbers.map { |ph| "#{formatted_phone_number ph.phone_number} (#{ph.phone_number_type})"}.join("<br>")
  end
  
  def service_type
    @appointment.service_type.present? ? @appointment.service_type.name : "Cleaning"
  end

  def recurrence
    if @appointment.subscription.repeat
      "Repeats #{recurrence_in_words(@appointment.subscription)}"
    else
      "One Time Service"
    end
  end

  def balance
    number_to_currency(@appointment.price)
  end

  def paid
    yes_no(@appointment.paid?)
  end

  def instructions
     @appointment.appointment_service_items.joins(:instruction).order("instructions.order ASC").map { |service_item| "#{service_item.field_name} " + (service_item.value_name.present? ? "- #{service_item.value_name}" : "") }.join("<br>")
  end
  
  def contact_name
    @appointment.customer.contact_name.present? ? @appointment.customer.contact_name : @appointment.customer.company_name
  end
  
  def full_contact_name
    @appointment.customer.full_name
  end
  
  def company_name
    @appointment.user.user_profile.company_name
  end
  
  def company_email
    @appointment.user.user_profile.company_email
  end
  
  def company_phone_number
    formatted_phone_number @appointment.user.user_profile.company_phone_number
  end
  
  def hashed_customer_items
    if @hashed_customer_items.blank?
      custom_items = @appointment.customer.customer_items.includes(:custom_field)
      @hashed_customer_items = {}
      custom_items.each do |item|
        @hashed_customer_items[item.custom_field.field_name.downcase.tr(' ', '_')] = item.value_name
      end
    end
    
    return @hashed_customer_items
  end
  
  def hashed_appointment_items
    if @hashed_appointment_items.blank?
      custom_items = @appointment.appointment_items.includes(:appointment_field)
      @hashed_appointment_items = {}
      custom_items.each do |item|
        @hashed_appointment_items[item.appointment_field.field_name.downcase.tr(' ', '_')] = item.value_name
      end
    end
    
    @hashed_appointment_items    
  end
  
  def logo
    "<img alt=\"Logo\" src=\"#{@appointment.user.user_profile.logo_url(:thumb)}\">" if @appointment.user.user_profile.logo.present?
  end
  
  def website
    if @appointment.user.user_profile.try(:website).present?
      "<a href=\"#{smart_add_url_protocol @appointment.user.user_profile.website}\">#{@appointment.user.user_profile.website}</a>"
    end
  end
  
  def facebook
    if @appointment.user.user_profile.try(:facebook_page).present?
      "<a href=\"#{smart_add_url_protocol @appointment.user.user_profile.facebook_page}\">Like us on Facebook!</a>"
    end
  end
  
  def status
    @appointment.status.try(:name)
  end

  def contact_first_name
    @appointment.customer.first_name
  end

  def contact_last_name
    @appointment.customer.last_name
  end

  def contact_company_name
    @appointment.customer.company_name
  end
  
end