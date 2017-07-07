class CustomerDrop < Liquid::Drop
  include ApplicationHelper
  include PhoneNumberHelper
  
  def initialize(customer)
    @customer = customer
  end
  
  def phone_number
    formatted_phone_number @customer.phone_numbers.first.try(:phone_number)
  end
  
  def billing_address
    if @customer.billing_address.present?
      address = @customer.billing_address
      "#{address.line1}, #{address.city}, #{address.state} #{address.postal_code}"
    end
  end
  
  def billing_address_alt
    if @customer.billing_address.present?
      address = @customer.billing_address
      "#{address.line1}<br>#{address.city}, #{address.state} #{address.postal_code}"
    end
  end

  def custom_fields
    @customer.customer_items.visible.map { |item| "<b>#{item.custom_field.field_name}</b> #{item.value_name}" }.join("<br>")
  end
  
  def contact_emails
    @customer.emails.map { |email| email.address }.join('<br>')
  end
  
  def contact_phone_numbers
    @customer.phone_numbers.map { |ph| "#{formatted_phone_number ph.phone_number} (#{ph.phone_number_type})"}.join("<br>")
  end

  
  def contact_name
    @customer.contact_name.present? ? @customer.contact_name : @customer.company_name
  end
  
  def full_name
    @customer.full_name
  end
  
  def company_name
    @customer.company_name
  end
  
  def first_name
    @customer.first_name
  end

  def notes
    @customer.notes
  end

  def logo
    "<img alt=\"Logo\" src=\"#{@customer.user.user_profile.logo_url(:thumb)}\">" if @customer.user.user_profile.logo.present?
  end
  
  def my_company_name
    @customer.user.user_profile.try(:company_name)
  end
  
  def my_phone_number
    formatted_phone_number @customer.user.user_profile.try(:company_phone_number)
  end

  def website
    if @customer.user.user_profile.try(:website).present?
      "<a href=\"#{smart_add_url_protocol @customer.user.user_profile.website}\">#{@customer.user.user_profile.website}</a>"
    end
  end
  
  def facebook
    if @customer.user.user_profile.try(:facebook_page).present?
      "<a href=\"#{smart_add_url_protocol @customer.user.user_profile.facebook_page}\">Like us on Facebook!</a>"
    end
  end

  
end