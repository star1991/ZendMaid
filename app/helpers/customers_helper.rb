module CustomersHelper
  
  def instant_booking_title(user)
    if user.user_profile.present?
      "#{user.user_profile.company_name} Instant Booking!"
    else
      "Instant Booking!"
    end
  end
  
end
