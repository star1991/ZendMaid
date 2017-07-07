module WorkOrdersHelper
  
  def email_subject(appointment)
    "[#{appointment.user.user_profile.company_name}] Details for appointment at #{formatted_time(appointment.start_time, :exact => true)} on #{appointment.start_time.strftime('%a, %b %d')}"
  end
  
end
