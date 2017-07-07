class TextTemplatesController < ApplicationController
  include PhoneNumberHelper
 
  before_filter :authenticate_user!
  
  layout 'application-admin'
  
  def edit
    @user = current_user
    @text_template = TextTemplate.find(params[:id])
  end
  
  def update
    @text_template = TextTemplate.find(params[:id])
    
    respond_to do |format|
      if @text_template.update_attributes(params[:text_template])
        format.html { redirect_to edit_text_template_path(@text_template), notice: 'Text template was successfully updated!' }
        format.json { head :no_content }
      else
        flash.now[:error] = "Please review the errors below"
        
        @user = current_user
        format.html { render action: "edit" }
        format.json { render json: @text_template.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  def preview
    @text_template = TextTemplate.find(params[:id])
      
    if params[:body_template].present?
      @text_template.body = params[:body_template]
    end

    body_template = Liquid::Template.parse(@text_template.body)
    @appointment = current_user.appointments.limit(1).first || Appointment.limit(1).first
    appointment_drop = AppointmentDrop.new(@appointment) 
    @body = body_template.render('appointment' => appointment_drop)[0..159]

    
    respond_to do |format|
      format.js
    end    
  end

  def generate
    @text_template = current_user.text_templates.find_by_id(params[:id])
        
    @appointment = Appointment.find_by_id(params[:appointment_id])
    
    if @text_template.template_type == "Work Order"
      @with_number, @without_number = employees_with_and_without_numbers(@appointment)
    else
      @with_number, @without_number = Hash[@appointment.customer.phone_numbers.where(:phone_number_type => "Cell").map { |phone_number| [phone_number.phone_number, "#{@appointment.customer.full_name} - #{formatted_phone_number phone_number.phone_number}"] }], {}
      
      if @with_number.length == 0
        @without_number[@appointment.customer.full_name] = edit_customer_path(@appointment.customer)
      end
    end
    
    body_template = Liquid::Template.parse(@text_template.body)
    
    appointment_drop = AppointmentDrop.new(@appointment)
    @body = body_template.render('appointment' => appointment_drop)[0..159]
  end

    
  def send_generated
    @appointment = Appointment.find_by_id(params[:appointment_id])
    #{employee.full_name} (#{formatted_phone_number employee.phone_number}
    client = Twilio::REST::Client.new(Rails.configuration.twilio[:account_sid], Rails.configuration.twilio[:auth_token])
    
    send_to = params[:generated_text][:sendable_numbers].select { |phone_number| params[:generated_text][phone_number.to_sym] == "1" }
    
    undeliverables = []
    delivered = false
    
    send_to.each do |phone_number|
      begin     
        client.account.messages.create(:from => Rails.configuration.twilio[:from], :to => phone_number, :body => params[:generated_text][:body])
        delivered = true
      rescue Twilio::REST::RequestError => e
        undeliverables << phone_number
        next
      end
    end
    
    # Notify if some employees were not sent texts
    if undeliverables.size > 0
      error_string =  "Texts were unable to be sent to the following numbers<br><ul>"
      undeliverables.each { |phone_number| error_string << "<li>#{formatted_phone_number phone_number}</li>" }
      error_string << "</ul>"
      
      flash[:error] = error_string.html_safe
    end
    
    if delivered
      flash[:notice] =  "Texts have been sent!"
      
      @appointment.sent_on["#{params[:generated_text][:template_type]} Text"] = Time.zone.now
      @appointment.allow_conflicts = true
      @appointment.save
    end
    
    respond_to do |format|
      format.html { redirect_to appointments_path }
    end
    
  end

  private
  
  def employees_with_and_without_numbers(appointment)
    with_phone_numbers, without_phone_numbers = {}, {}
    appointment.employees.each do |employee|
      if employee.phone_number.present?
        with_phone_numbers[employee.phone_number] = "#{employee.full_name} (#{formatted_phone_number employee.phone_number})"
      else
        without_phone_numbers[employee.full_name] = edit_employee_path(employee)
      end
    end
    
    return with_phone_numbers, without_phone_numbers    
  end

end
