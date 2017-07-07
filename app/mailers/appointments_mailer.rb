class AppointmentsMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  include AppointmentsHelper
  
  default :from => "no-reply@zenmaid.com"
  
  helper :appointments
  helper :phone_number
  helper :application
  
  def view_appointment(appointment)
    @appointment = appointment
    @user = appointment.user
    mail(:to => "#{appointment.customer.first_name} #{appointment.customer.last_name} <#{appointment.customer.email}>", :reply_to => @user.user_profile.company_email, :subject => "[#{@user.user_profile.company_name}] Thank you for booking with us!")
  end
  
  def notify_client_of_booking(appointment)
    @user = appointment.user
    @appointment = appointment
    mail(:to => @user.email, :subject => "[ZenMaid] Someone just booked an appointment with you at ZenMaid.net!")
  end
  
  def appointment_reminder(appointment)
    logger.debug("Appointment Reminder: #{appointment}")
    @appointment = appointment
    @user = appointment.user
    mail(:to => "#{appointment.customer.first_name} #{appointment.customer.last_name} <#{appointment.customer.email}>", :reply_to => @user.user_profile.company_email, :subject => "[#{@user.user_profile.company_name}] Reminder for cleaning scheduled tomorrow")
  end
  
  def digest_of_days_appointments(user)
    @user = user
    @upcoming_appointments = user.appointments.where(:start_time => (DateTime.now.beginning_of_day)..(DateTime.now.beginning_of_day + 1.day)).order("appointments.start_time ASC")
    if @upcoming_appointments.present?
      mail(:to => user.email, :subject => "[ZenMaid] Today's Appointments")
    end
  end
  
  def email_work_order(appointment, employee, subject, body)
    @body = body
    mail(:to => employee.email, :reply_to => appointment.user.user_profile.company_email, :subject => subject)
  end
  
  def work_order_digest(to, from, subject, appointments, body_template)
    @body_template = body_template
    @appointments = appointments
    
    mail(:to => to, :reply_to => from, :subject => subject)
  end
  
  def email_template(appointment, to, title_template, body_template)
    appointment_drop = AppointmentDrop.new(appointment)
    
    @body = body_template.render('appointment' => appointment_drop)
    
    mail(:to => to, :reply_to => appointment.user.user_profile.company_email, :subject => title_template.render('appointment' => appointment_drop))
  end
  
  def email_generated(to, from, title, body)
    @body = body
    
    mail(:to => to, :reply_to => from, :subject => title)
  end
  
  def email_employee_work_order(employee, current_employee, body_template, to, from)  
    @body_template = body_template
    @from = from
    @to = to
    @employee = employee

    attachments["work_order.pdf"] = WickedPdf.new.pdf_from_string( 
      render_to_string( :pdf => 'work_order', :template => 'employees/employee_work_order', :layout =>   "layouts/application-pdf.pdf")
    )  
 
     mail(:to => employee.email, :reply_to => current_employee.email, :subject => "[#{current_employee.user.user_profile.company_name}] Your work order for #{@from.strftime('%-m/%-d/%Y')} - #{@to.strftime('%-m/%-d/%Y')}",  :parts_order => [ "text/html", "text/enriched", "text/plain", "application/pdf" ]  ) do |format|
       format.html
     end
  end
  
  def email_employee_work_order_digest(employees_with_appointments, employee, body_template, to, from)
    @body_template = body_template
    @from = from
    @to = to
    @employees_with_appointments = employees_with_appointments  

    attachments["work_order.pdf"] = {
         :mime_type => 'application/pdf',
         :content => WickedPdf.new.pdf_from_string(render_to_string( :pdf => 'work_order', :template => 'employees/print_work_order', :layout => "layouts/application-pdf.pdf", :page_size => "Letter"))
         }

    mail(:to => employee.email, :subject => "[ZenMaid] Work orders for selected employees for #{@from.strftime('%-m/%-d/%Y')} - #{@to.strftime('%-m/%-d/%Y')}" , :parts_order => [ "text/html", "text/enriched", "text/plain", "application/pdf" ]) do |format|
       format.html
    end
  end

  def email_all_work_order_digest(appointments, employee, body_template, to, from)
    @body_template = body_template
    @from = from
    @to = to
    @appointments = appointments  

    attachments["work_order.pdf"] = {
         :mime_type => 'application/pdf',
         :content => WickedPdf.new.pdf_from_string(render_to_string( :pdf => 'work_order', :template => 'employees/print_work_order', :layout => "layouts/application-pdf.pdf", :page_size => "Letter"))
         }

    mail(:to => employee.email, :subject => "[ZenMaid] Work orders for all appointments from #{@from.strftime('%-m/%-d/%Y')} - #{@to.strftime('%-m/%-d/%Y')}" , :parts_order => [ "text/html", "text/enriched", "text/plain", "application/pdf" ]) do |format|
       format.html
    end
  end

  def from_quickbooks_finished_syncing(to)
    mail(:to => to, :subject => "[ZenMaid] Your contacts from Quickbooks have been synced!")
  end

  def to_quickbooks_finished_syncing(to)
    mail(:to => to, :subject => "[ZenMaid] Your contacts have been synced to Quickbooks!")
  end

  def quickbooks_both_finished_syncing(to)
    mail(:to => to, :subject => "[ZenMaid] Your contacts have been synced with Quickbooks!")
  end

  def mailchimp_finished_syncing(to)
    mail(:to => to, :subject => "[ZenMaid] Your contacts have been synced to Mailchimp!")
  end

end
