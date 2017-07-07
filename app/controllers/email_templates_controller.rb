class EmailTemplatesController < ApplicationController
  
  before_filter :authenticate_user!
  
  layout 'application-admin'
  
  def send_mass_email
    if params[:id].present?
      @email_template = current_user.email_templates.find_by_id(params[:id])
      @email_template.assign_attributes(params[:email_template])
    else
      @email_template = current_user.email_templates.build(params[:email_template])
    end

    respond_to do |format|
      if @email_template.save
          case @email_template.send_to
          when "All Contacts" 
            recipients = current_user.customers
          when "Leads Only"
            recipients = current_user.customers.where(:lead => true)
          when "Customers Only"
            recipients = current_user.customers.where(:lead => false)
          else
          end 
          
          title_template = Liquid::Template.parse(@email_template.title)
          body_template = Liquid::Template.parse(@email_template.body)         

          recipients.includes(:automatable_emails).each do |recipient|
            if recipient.automatable_emails.size > 0
              customer_drop = CustomerDrop.new(recipient)
              title = title_template.render('customer' => customer_drop)
              body = body_template.render('customer' => customer_drop) 

              AppointmentsMailer.email_generated(recipient.automatable_emails.map(&:address), current_user.user_profile.try(:company_email), title, body).deliver
            end
          end

          format.html { redirect_to customers_path, :notice => "Mass email has been successfully sent!"}
      else
        @recipient_string = @email_template.get_recipient_string
        flash.now[:error] = "Oops, something went wrong. Please correct the errors below and try again!"
        format.html { render action: "prep_mass_email" }
      end
    end
  end

  def prep_mass_email
    if params[:email_template][:email_template_id].present?
      @email_template = current_user.email_templates.find_by_id(params[:email_template][:email_template_id])
    else
      @email_template = current_user.email_templates.build
      @email_template.template_resource = "Customer"
      @email_template.mass_email = true     
    end

    @email_template.send_to = params[:email_template][:send_to]

    @recipient_string = @email_template.get_recipient_string
  end

  def new
    @user = current_user
    @email_template = @user.email_templates.build
    @email_template.template_resource = "Customer"
    @email_template.mass_email = true
  end
  
  def new_admin
    @user = current_user
    @email_template = @user.email_templates.build
    @email_template.template_resource = "Customer"
    @email_template.mass_email = false

    render 'new_admin'
  end

  def create
    @user = current_user
    @email_template = current_user.email_templates.build(params[:email_template])

    respond_to do |format|
      if @email_template.save
        format.html { redirect_to edit_email_template_path(@email_template), notice: 'Template was successfully created.' }
      else

        flash.now[:error] = "Oops! Something went wrong, please review the errors below"      
        format.html { render action: "new" }
      end
    end
  end
  
  def show
  end

  def edit
    @user = current_user
    @email_template = @user.email_templates.find(params[:id])
  end
  
  def update
    @email_template = EmailTemplate.find(params[:id])
    
    respond_to do |format|
      if @email_template.update_attributes(params[:email_template])
        format.html { redirect_to edit_email_template_path(@email_template), notice: 'Email template was successfully updated!' }
        format.json { head :no_content }
      else
        flash.now[:error] = "Please review the errors below"
        
        @user = current_user
        format.html { render action: "edit" }
        format.json { render json: @email_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def preview
    
    begin
      @email_template = EmailTemplate.find(params[:id])
    rescue
      @email_template = EmailTemplate.new
      @email_template.template_resource = "Customer"
    end

    if params[:subject_template].present?
      @email_template.title = params[:subject_template]
    end
    
    if params[:body_template].present?
      @email_template.body = params[:body_template]
    end

    title_template = Liquid::Template.parse(@email_template.title)
    body_template = Liquid::Template.parse(@email_template.body)

    case @email_template.template_resource
    when "Appointment"
      @appointment = current_user.appointments.limit(1).first || Appointment.limit(1).first
      appointment_drop = AppointmentDrop.new(@appointment) 
      @title = title_template.render('appointment' => appointment_drop)
      @body = body_template.render('appointment' => appointment_drop)
    when "Customer"
      @customer = current_user.customers.limit(1).first || Customer.limit(1).first
      customer_drop = CustomerDrop.new(@customer)
      @title = title_template.render('customer' => customer_drop)
      @body = body_template.render('customer' => customer_drop)
    when "InstantBooking"
      @instant_booking = current_user.instant_bookings.limit(1).first || InstantBooking.limit(1).first
      instant_booking_drop = InstantBookingDrop.new(@instant_booking)
      @title = title_template.render('booking' => instant_booking_drop)
      @body = body_template.render('booking' => instant_booking_drop)
    end
    
    respond_to do |format|
      format.js
    end
  end

  def confirmation_email
    @appointment = current_user.appointments.find_by_id(params[:id])
    
    if @appointment.customer.automatable_emails.size > 0
      @confirmation_email = current_user.email_templates.find_by_template_type("Appointment Confirmation")
    end
  end


  def send_email
    @email_template = current_user.email_templates.find_by_id(params[:id])

    @appointment = Appointment.find_by_id(params[:appointment_id])
    
    if @email_template.template_type == "Appointment Confirmation"
      email_list = @appointment.customer.automatable_emails.map(&:address)
    end
    
    if email_list.size > 0
      title_template = Liquid::Template.parse(@email_template.title)
      body_template = Liquid::Template.parse(@email_template.body)
      AppointmentsMailer.email_template(@appointment, email_list, title_template, body_template).deliver
      
      @appointment.sent_on["#{@email_template.template_type} Email"] = Time.zone.now
      @appointment.allow_conflicts = true
      @appointment.save
      
      render 'send_email'
    else
      render :nothing => true      
    end

  end

  def generate
    @email_template = current_user.email_templates.find_by_id(params[:id])

    title_template = Liquid::Template.parse(@email_template.title)
    body_template = Liquid::Template.parse(@email_template.body)
    
    case @email_template.template_resource
    when 'Appointment'
      @appointment = Appointment.find_by_id(params[:appointment_id])
    
      if @email_template.template_type == "Work Order"
        @with_email, @without_email = employees_with_and_without_emails(@appointment)
      else
        @with_email, @without_email = get_customer_emails(@appointment.customer)
      end

      appointment_drop = AppointmentDrop.new(@appointment)
      @title = title_template.render('appointment' => appointment_drop)
      @body = body_template.render('appointment' => appointment_drop)   
    when 'Customer'
      @customer = current_user.customers.find_by_id(params[:customer_id])
            
      @with_email, @without_email = get_customer_emails(@customer)
      
      customer_drop = CustomerDrop.new(@customer)
      @title = title_template.render('customer' => customer_drop)
      @body = body_template.render('customer' => customer_drop)           
    end
    
  end
  
  def send_generated
    
    send_to = params[:generated_email][:sendable_emails].select { |email| params[:generated_email][email.to_sym] == "1" }
    
    if send_to.size > 0
      AppointmentsMailer.email_generated(send_to, current_user.user_profile.try(:company_email), params[:generated_email][:subject], params[:generated_email][:body]).deliver
      
      if params[:appointment_id].present?
        @appointment = Appointment.find_by_id(params[:appointment_id])
        @appointment.sent_on["#{params[:generated_email][:template_type]} Email"] = Time.zone.now
        @appointment.allow_conflicts = true
        @appointment.save
        respond_to do |format|
          format.html { redirect_to appointments_path, notice: 'Email has been sent!'}
        end
      
      elsif params[:customer_id].present?
        @customer = Customer.find_by_id(params[:customer_id])
        @customer.sent_on["#{params[:generated_email][:template_type]} Email"] = Time.zone.now
        @customer.save
        respond_to do |format|
          format.html { redirect_to customer_path(@customer), notice: 'Email has been sent!'}
        end
        
      end
    end
    
  end

  def destroy
    @email_template = current_user.email_templates.where(:mass_email => true).find_by_id(params[:id])
    @email_template.destroy

    respond_to do |format|
      format.html { redirect_to new_email_template_path, :notice => "Template has been successfully deleted!" }
      format.json { head :no_content }
    end
  end

  # Helper methods
  
  def employees_with_and_without_emails(appointment)
    with_emails, without_emails = {}, {}
    appointment.employees.each do |employee|
      if employee.email.present?
        with_emails[employee.email] = "#{employee.full_name} (#{employee.email})"
      else
        without_emails[employee.full_name] = edit_employee_path(employee)
      end
    end
    
    return with_emails, without_emails
  end
  
  def get_customer_emails(customer)
    with_email, without_email = Hash[customer.emails.map { |email| [email.address, "#{customer.full_name} <#{email.address}>"] }], {}
      
    if customer.emails.size == 0
      without_email[customer.full_name] = edit_customer_path(customer)
    end    
  
    return with_email, without_email  
  end
  
end
