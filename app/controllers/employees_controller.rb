class EmployeesController < ApplicationController
  
  before_filter :employee_owner
  
  layout :resolve_layout

  # GET /employees
  # GET /employees.json
  def index
    if params[:filter] == 'all'
      @employees = current_user.employees
    elsif params[:filter] == 'inactive'
      @employees = current_user.employees.where(:active => false)
    else
      @employees = current_user.employees.active
    end    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @employees }
    end
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
    @employee = Employee.find(params[:id])
    @subscription = Subscription.new()

    session[:employee_id] = params[:id]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @employee }
    end
  end

  # retrieve the employee-assigned appts for fullcalendar
  # GET /get_assigned_appts
  def get_assigned_appts
    
    @employee = current_user.employees.find(session[:employee_id])
    
    events = [] 

    # Server-side validation required to prevent client-side tampering
    if @employee.present?
      @appointments = @employee.assigned_appointments.where('appointments.use_as_prototype = ?', false)

      # filter by the datetime object via params from fullcalendar
      @events = @appointments.active.find(:all, :conditions => ["start_time >= '#{Time.at(params['start'].to_i).to_formatted_s(:db)}' and end_time <= '#{Time.at(params['end'].to_i).to_formatted_s(:db)}'"] )
      @events.each do |event|
        if event
          events << {:id => event.id, :title => event.customer.full_name, :url => "/appointments/"+event.id.to_s+"/edit", :description => "Description here", :start => "#{event.start_time.iso8601}", :end => "#{event.end_time.iso8601}", :allDay => false}
        end
      end
    end

    render :text => events.to_json
  end
  #
  # retrieve the employeed predefined obligation for fullcalendar
  # GET /get_predefined_ob
  def get_predefined_ob
    logger.debug "Session get predefined obj #{session}"
    @employee_id = session[:employee_id] 
    
    @employee = Employee.find(@employee_id)
    events = [] 

    # Server-side validation required to prevent client-side tampering
    if @employee.user == current_user
      @obligations = @employee.predefined_obligations
      
      events = []
      @obligations.each do |obligation|
        events = events.concat obligation.get_valid_start_times_between(Time.at(params['start'].to_i).to_formatted_s(:db), Time.at(params['end'].to_i).to_formatted_s(:db))
      end
    end

    render :text => events.to_json
  end

  

  # GET /employees/new
  # GET /employees/new.json
  def new
    @employee = Employee.new
    @employee.build_address
    current_user.employee_fields.each do |employee_field|
      @employee.employee_items.build(:custom_field_id => employee_field.id, :value_name => employee_field.default)
    end

    @employee.allow_sign_in = current_user.allow_employee_sign_in
    @employee.pay_type = current_user.default_pay_type
    @employee.pay_rate = current_user.default_pay_rate

    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @employee }
    end
  end

  # GET /employees/1/edit
  def edit
    @employee = Employee.find(params[:id])
    if not @employee.address
        @employee.build_address
    end
    
    @hide_password_fields = @employee.password_fields_valid?
  end

  def edit_my_account
    @employee = current_employee
    
    @hide_password_fields = @employee.password_fields_valid?
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(params[:employee])
    @employee.user = current_user

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render json: @employee, status: :created, location: @employee }
      else
        if not @employee.address
          @employee.build_address
        end

        flash.now[:error] = "Please review the errors below"      
        format.html { render action: "new" }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /employees/1
  # PUT /employees/1.json
  def update
    @employee = Employee.find(params[:id])

    respond_to do |format|
      if @employee.update_attributes(params[:employee])
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { head :no_content }
      else
        if not @employee.address
          @employee.build_address
        end
        @hide_password_fields = @employee.password_fields_valid?
        
        flash.now[:error] = "Please review the errors below"        
        format.html { render action: "edit" }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_my_account
    @employee = current_employee

    respond_to do |format|
      if @employee.update_attributes(params[:employee])
        sign_in @employee, :bypass => true
        
        format.html { redirect_to edit_my_account_employees_path, :notice => "Your account has been updated!" }
      else
        @hide_password_fields = @employee.password_fields_valid?
        
        flash.now[:error] = "Please review the errors below"        
        format.html { render action: "edit_my_account" }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to employees_path }
      format.json { head :no_content }
    end
  end

  # GET /employees/dashboard
  def dashboard
    @employee = current_employee
    session[:employee_id] = @employee.id
  end
  
  def route_sheet
    from = params[:work_order][:from].present? ? Time.zone.parse(params[:work_order][:from]).beginning_of_day : Time.zone.now.beginning_of_day
    to = params[:work_order][:to].present? ? Time.zone.parse(params[:work_order][:to]).end_of_day : from.end_of_day
    
    if params[:work_order][:all] == "1"
      @appointments = current_user.appointments.includes(:status).actual.where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).order('appointments.start_time ASC')
    elsif params[:work_order][:group] == "Employees"
      employee_ids = params[:work_order][:employees].keys.select { |k| params[:work_order][:employees][k] == '0' }
      @employees_with_appointments = Employee.includes({:assigned_appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).where("employees.id in (?)", employee_ids).order("appointments.start_time ASC")
    else
      team_ids = params[:work_order][:teams].keys.select { |k| params[:work_order][:teams][k] == '0' }
      @teams_with_appointments = Team.includes({:appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).where("teams.id in (?)", team_ids).order("appointments.start_time ASC")
    end

    @from = from
    @to = to
    
    if !(@appointments.blank? && @employees_with_appointments.blank? && @teams_with_appointments.blank?)
      respond_to do |format|
        format.pdf do
          render :pdf => "route_sheet",
               :layout => 'layouts/application-pdf.pdf',
               :margin => {
                 :top => 20,
                 :bottom => 25,
                 :left => 20,
                 :right => 20
               }
        end
      end
    else
      if params[:work_order][:all] == "1"
        flash[:error] = "Oops! No valid appointments found for the selected date range. Please check to make sure that appointment statuses are one which are configured to be placed in work orders."
      elsif params[:work_order][:group] == "Employees"
        flash[:error] = "Oops! No valid appointments found for the selected employees and date range. Please check to make sure that appointments have cleaners assigned to them and that the appointment status is one which is configured to be placed in work orders."      
      else
        flash[:error] = "Oops! No valid appointments found for the selected teams and date range. Please check to make sure that appointments have teams assigned to them and that the appointment status is one which is configured to be placed in work orders."        
      end
      
      redirect_to appointments_path      
    end
  end

  def print_work_order
    work_order_template = current_user.email_templates.find_by_template_type("Work Order")
    @body_template = Liquid::Template.parse(work_order_template.body)
    
    from = params[:work_order][:from_print_date].present? ? Time.zone.parse(params[:work_order][:from_print_date]).beginning_of_day : Time.zone.now.beginning_of_day
    to = params[:work_order][:to_print_date].present? ? Time.zone.parse(params[:work_order][:to_print_date]).end_of_day : from.end_of_day
    
    if params[:work_order][:all] == "1"
      @appointments = current_user.appointments.includes(:status).actual.where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).order('appointments.start_time ASC')
    elsif params[:work_order][:group] == "Employees"
      employee_ids = params[:work_order][:employees].keys.select { |k| params[:work_order][:employees][k] == '0' }
      @employees_with_appointments = Employee.includes({:assigned_appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).where("employees.id in (?)", employee_ids).order("appointments.start_time ASC")
    else
      team_ids = params[:work_order][:teams].keys.select { |k| params[:work_order][:teams][k] == '0' }
      @teams_with_appointments = Team.includes({:appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).where("teams.id in (?)", team_ids).order("appointments.start_time ASC")
    end

    @from = from
    @to = to
    
    if !(@appointments.blank? && @employees_with_appointments.blank? && @teams_with_appointments.blank?)
      respond_to do |format|
        format.pdf do
          render :pdf => "print_work_order",
               :layout => 'layouts/application-pdf.pdf',
               :margin => {
                 :top => 20,
                 :bottom => 25,
                 :left => 20,
                 :right => 20
               }
        end
      end
    else
      if params[:work_order][:all] == "1"
        flash[:error] = "Oops! No valid appointments found for the selected date range. Please check to make sure that appointment statuses are one which are configured to be placed in work orders."
      elsif params[:work_order][:group] == "Employees"
        flash[:error] = "Oops! No valid appointments found for the selected employees and date range. Please check to make sure that appointments have cleaners assigned to them and that the appointment status is one which is configured to be placed in work orders."      
      else
        flash[:error] = "Oops! No valid appointments found for the selected teams and date range. Please check to make sure that appointments have teams assigned to them and that the appointment status is one which is configured to be placed in work orders."        
      end
      
      redirect_to appointments_path      
    end
  end

  def email_work_order
    work_order_template = current_user.email_templates.find_by_template_type("Work Order")    
    @body_template = Liquid::Template.parse(work_order_template.body)

    from = params[:work_order][:from_email_date].present? ? Time.zone.parse(params[:work_order][:from_email_date]).beginning_of_day : Time.zone.now.beginning_of_day
    to = params[:work_order][:to_email_date].present? ? Time.zone.parse(params[:work_order][:to_email_date]).end_of_day : from.end_of_day
    
    employee_ids = params[:work_order][:employees].keys.select { |k| params[:work_order][:employees][k] == '0' }
    @employees_with_appointments = Employee.includes({:assigned_appointments => :status}).where("appointments.use_as_prototype = ?", false).where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).where("employees.id in (?)", employee_ids).order("appointments.start_time ASC")

    if params[:work_order][:all] == "1"
      @appointments = current_user.appointments.includes(:status).actual.where('statuses.show_in_work_orders = ?', true).where("appointments.start_time < ? AND appointments.start_time > ?", to, from).order('appointments.start_time ASC')
    end

    if @employees_with_appointments.present? || @appointments.present?
      if params[:work_order][:all_employees] == "1"
        @employees_with_appointments.each do |employee|
          if employee.email.present?
            AppointmentsMailer.email_employee_work_order(employee, current_employee, @body_template, to, from).deliver
          end
        end
      end
    
      if params[:work_order][:me] == "1"
        AppointmentsMailer.email_employee_work_order_digest(@employees_with_appointments, current_employee, @body_template, to, from).deliver
      end

      if params[:work_order][:all] == "1"
        AppointmentsMailer.email_all_work_order_digest(@appointments, current_employee, @body_template, to, from).deliver
      end      
          
      redirect_to appointments_path, :notice => "Work orders have been emailed!"
    else
      flash[:error] = "Oops! No valid appointments found for the selected date range. Please check to make sure that appointments have cleaners assigned to them and that the appointment status is one which is configured to be placed in work orders."
      redirect_to appointments_path
    end
  end

  def pay_rate
    @employee = current_user.employees.find(params[:id])   
    
    respond_to do |format|
      format.js
    end
  end
  
  def edit_pay_rate
    @employee = current_user.employees.find(params[:id])
    
    if @employee.update_attributes(params[:employee])
      @payroll_entry = PayrollEntry.find(params[:entry_id])
      
      @payroll_entry.pay_rate = @employee.pay_rate
      @payroll_entry.pay_type = @employee.pay_type
      @payroll_entry.save!
      
      render 'edit_pay_rate_success.js.erb'
    else
      render 'edit_pay_rate_error.js.erb'
    end
  end

  def inactivate
    @employee = current_user.employees.find(params[:id])
    
    #De-assign from all teams
    @employee.teams_employees.destroy_all
    
    @employee.assignments.joins(:appointment).where("appointments.start_time > ?", Time.zone.now.beginning_of_day).destroy_all
    
    @employee.active = false
    @employee.inactivated_on = Time.zone.now
    
    if @employee.save
      redirect_to @employee, :notice => "Employee was successfully inactivated"
    end
  end
  
  def reactivate
    @employee = current_user.employees.find(params[:id])
    
    @employee.active = true
    if @employee.save
      redirect_to @employee, :notice => "Employee was successfully reactivated"
    end
  end

  protected

  def employee_owner
    case action_name
    when 'dashboard'
      if current_employee.blank?
        redirect_to new_employee_session_path, notice: "You must sign in to view this page. Please contact your employer if you do not have a username and password"
      end
    when 'get_assigned_appts'
      if current_employee.blank? && current_user.blank?
        redirect_to new_employee_session_path, notice: "You must sign in to view this page. Please contact your employer if you do not have a username and password"
      end
    else
      if current_user.blank? || (params[:id].present? && current_user != Employee.find_by_id(params[:id]).try(:user))
        redirect_to user_root_path, notice: "Please sign in"
      elsif !current_user.active?
        flash[:error] = "Your account has been deactivated, please email us at support@zenmaid.com to resolve this issue."
        redirect_to user_root_path
      end
    end
  end
  
  def resolve_layout
    case action_name
    when 'dashboard'
      'application-calendar-employee'
    else
      'application-admin'
    end
  end

  private
  
  def after_update_path_for(resource)
    edit_my_account_employees_path
  end
  
end
