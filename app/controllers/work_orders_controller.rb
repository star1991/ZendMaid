class WorkOrdersController < ApplicationController
  
  layout 'application-admin'
  before_filter :appointment_owner
  
  def new
    work_order_template = current_user.email_templates.find_by_template_type("Work Order")
        
    @appointment = Appointment.find_by_id(params[:appointment_id])
    
    
    title_template = Liquid::Template.parse(work_order_template.title)
    body_template = Liquid::Template.parse(work_order_template.body)
    
    appointment_drop = AppointmentDrop.new(@appointment)
    @title = title_template.render('appointment' => appointment_drop)
    @body = body_template.render('appointment' => appointment_drop)
  end
  
  def email_work_order
    @appointment = Appointment.find_by_id(params[:appointment_id])
    
    @appointment.employees.each do |employee|
      if employee.email.present? && params[:work_order_email][employee.email.to_sym].to_i == 1
        AppointmentsMailer.email_work_order(@appointment, employee, params[:work_order_email][:subject], params[:work_order_email][:body]).deliver
      end
    end
    
    respond_to do |format|
      format.html { redirect_to edit_appointment_path(@appointment), notice: 'Work Orders have been successfully emailed!'}
    end
    
  end
  
  protected
  
  def appointment_owner
    if current_user.blank? || current_user != Appointment.find_by_id(params[:appointment_id]).user
      redirect_to user_root_path, notice: "Please sign in"
    end
  end
  
end
