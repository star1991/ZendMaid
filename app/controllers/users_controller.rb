class UsersController < Devise::RegistrationsController
  before_filter :sign_in_user
  layout :resolve_layout
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end 

  def revenue_panel
    @from = params[:date_range][:from].present? ? Time.zone.parse(params[:date_range][:from]).beginning_of_day : (Time.zone.now - 1.week).beginning_of_day
    @to =  params[:date_range][:to].present? ? Time.zone.parse(params[:date_range][:to]).end_of_day : Time.zone.now.end_of_day

    appointments = current_user.appointments.actual.joins(:status).where("statuses.use_for_invoice = ?", true).where(:start_time => @from..@to)
    payrolls = current_user.payrolls.where(:draft => false).where(:end_date => @from..@to)

    revenue_bin = Hash.new(0)
    outstanding_revenue_bin = Hash.new(0)
    @appointments_count = 0
    @outstanding_appointments_count = 0

    @revenue, @outstanding_revenue = 0, 0
    appointments.each do |appointment|
      price = appointment.price.to_f
      #revenue_bin[appointment.start_time.beginning_of_day.to_i] += price
      revenue_bin[appointment.start_time.strftime("%b %d, %Y")] += price

      @revenue += price
      @appointments_count += 1
      if !appointment.paid? 
        @outstanding_appointments_count += 1
        @outstanding_revenue += price
      end
    end
  
    @payrolls_count = 0
    @payroll = 0
    payrolls.each do |payroll|
      total_pay = payroll.total_pay.to_f
      @payrolls_count += 1
      @payroll += total_pay

    end

    @revenue_data = []
    days = ((@to - @from)/86400).to_i - 1
    current_time = @from
    for i in 0..days
      #js_time = (current_time.beginning_of_day.to_i)*1000
      formatted_date = current_time.strftime("%b %d, %Y")
      @revenue_data << [formatted_date, revenue_bin[formatted_date]]
      current_time += 1.day
    end

    respond_to do |format|
      format.js
    end

  end

  # GET /dashboard
  # GET /users/1.json
  def show    
    @user = current_user
    @appointments = @user.appointments
    @customers = @user.customers
    
    @date = params[:go_to].present? && params[:go_to][:date].present? ? Time.zone.parse(params[:go_to][:date]) : Time.zone.now
    
    @draft_payroll = @user.payrolls.find_by_draft(true)
    @last_run_payroll = @user.payrolls.where(:draft => false).order('payroll_number DESC').limit(1).try(:first)
    
    @overdue_tasks = current_user.tasks.overdue.size
    @tasks = current_user.tasks.order('due_date DESC').where("due_date = ?", Time.zone.now.to_date)

    @from = (Time.zone.now - 1.week).beginning_of_day
    @to =  Time.zone.now.end_of_day

    respond_to do |format|
      format.html {
        
        if current_employee.present? && !current_employee.admin?
          redirect_to dashboard_employees_path
        end
      }
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @user.plan_id = params[:plan]
    
    respond_with @user
  end



  # GET /users/edit
  def edit

    redirect_to edit_my_account_employees_path
    
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        @user.build_default_entries
        LeadsMailer.notify_of_lead_capture(@user).deliver
        sign_in @user.employees.first
        format.html { redirect_to edit_user_registration_path, notice: 'Congratulations! Welcome to ZenMaid!' }
      else
   
        format.html { render action: "new" }
      end
    end
  end

  # GET /systems_week_signup
  def systems_week_signup
    @user = User.new
    @user.plan_id = 'systems-week-launch'

    respond_with @user
  end

  def systems_week_signup_create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        @user.build_default_entries
        LeadsMailer.notify_of_lead_capture(@user).deliver
        sign_in @user.employees.first
        format.html { redirect_to edit_user_registration_path, notice: 'Congratulations! Welcome to ZenMaid!' }
      else
   
        format.html { render action: "systems_week_signup" }
      end
    end
  end

  def sign_up
    @user = User.new
    @user.plan_id = params[:plan]

    respond_with @user
  end

  def sign_up_create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        @user.build_default_entries
        LeadsMailer.notify_of_lead_capture(@user).deliver
        sign_in @user.employees.first
        format.html { redirect_to edit_user_registration_path, notice: 'Congratulations! Welcome to ZenMaid!' }
      else
   
        format.html { render action: "sign_up" }
      end
    end
  end  

  # POST /billing
  def create_plan
    begin
      @user = User.find(current_user.id)
      
      if @user.update_or_subscribe_to_plan params
        flash.now[:notice] = "Thank you for subscribing!"
        render "billing"
      end
    
    rescue => e
      flash.now[:error] = "Sorry! There was an error in the sign up process: #{e.message}. Please try again."
      render "billing"
    end
  end

  def subscribe_plan
    @user = current_user
    @user.card_number = params[:user][:card_number]
    @user.expiry_month = params[:user][:expiry_month]
    @user.expiry_year = params[:user][:expiry_year]
    @user.cvc = params[:user][:cvc]
    @user.plan_id = params[:user][:plan_id]

    if @user.create_plan
      flash.now[:notice] = 'Thank you for subscribing!'
      @user.active = true
      @user.save
    else
      @user.plan_id = nil        
    end
    render "billing"
  end

  def billing
    @user = current_user
    render "billing"
  end

  def credit_card_processing
    @user = current_user
    render 'credit_card_processing'
  end

  def edit_customized_fields
    @user = current_user
    render 'customized_fields'
  end
  
  def customer_custom_fields
    @user = current_user
  end
  
  def employee_custom_fields
    @user = current_user
  end
  
  def appointment_custom_fields
    @user = current_user
  end
  
  def instruction_custom_fields
    @user = current_user
  end
  
  def edit_statuses
    @user = current_user
  end
  
  def edit_calendar_options
    @user = current_user
    render 'calendar_options'
  end
  
  def edit_teams
    @user = current_user
    render 'edit_teams'
  end
  
  def instant_booking
    @user = current_user
    render 'instant_booking_fields'
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    @user = User.find(current_user.id)

    # non admin user should not allow to mass assign plan
    unless current_admin.present?
      params[:user].delete("plan_id")
    end

    if @user.update_attributes(params[:user])

      if params[:custom_fields_page]
        @user.create_all_missing_custom_items(params[:custom_fields_type])
      end
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user), :notice => "Hooray! You updated your account successfully."
    else
      flash.now[:error] = "Oops! Something went wrong when trying to save your data, please review the errors below and try again."

      if params[:custom_fields_page]
        if params[:custom_fields_type] == 'customer'
          render 'customer_custom_fields'
        elsif params[:custom_fields_type] == 'appointment'
          render 'appointment_custom_fields'
        elsif params[:custom_fields_type] == 'employee'
          render 'employee_custom_fields'
        elsif params[:custom_fields_type] == 'instruction'
          render 'instruction_custom_fields'
        end
      elsif params[:edit_statuses]
        render 'edit_statuses'
      elsif params[:calendar_options_page]
        render "calender_options"
      elsif params[:email_templates_page]
        render "email_templates"
      elsif params[:edit_teams_page]
        render 'edit_teams'
      elsif params[:instant_booking_fields_page]
        render 'instant_booking_fields'
      elsif params[:credit_card_processing_page]
        render 'credit_card_processing'
      else
        @hide_password_fields = @user.password_fields_valid?
        render "edit"
      end
    end
  end

  def qb_disconnect
    current_user.qb_access_token = nil
    current_user.qb_access_secret = nil
    current_user.qb_company_id = nil

    current_user.qb_token_expires_at = nil
    current_user.qb_reconnect_token_at = nil
    current_user.save!

    redirect_to quickbooks_users_path, :notice => "You have successfully disconnected ZenMaid from QuickBooks!"
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    super
  end
  
  def qb_oauth_callback
    at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    
    current_user.qb_access_token = at.token
    current_user.qb_access_secret = at.secret
    current_user.qb_company_id = params['realmId']

    current_user.qb_token_expires_at = 6.months.from_now
    current_user.qb_reconnect_token_at = 5.months.from_now
    current_user.save!

    render 'quickbooks'


  end

  def qb_authenticate
    callback = qb_oauth_callback_users_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def quickbooks

  end

  def cancel
    super
  end
  
  def import_customers
    @num_customers = current_user.customers.size
  end

  def export_customers
    
    additional_fields = params.select{|key,value| value == 'true'}.keys
    Delayed::Job.enqueue ::CustomersExportJob.new(additional_fields, params[:filter], params[:current_filter], current_user)

    redirect_to import_customers_page_path
    flash[:notice] ="Your export customer request has been enequed successfully"

    # csv_file = Customer.export_to_csv(customers.includes(:emails, :phone_numbers, :customer_items, :addresses), additional_fields)
    # send_data csv_file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;filename=customer.csv"
  end

  def mailchimp_setting
    @auth = Auth.where(:provider => 'mailchimp', :user_id => current_user.id).last
    render "mailchimp_setting"
  end

  private
    
    def sign_in_user
      if not ["new", "create", "update", "systems_week_signup_create", "systems_week_signup", "sign_up", "sign_up_create"].include?(params[:action])
        if current_user.blank?
          redirect_to new_employee_session_path
        elsif !current_user.active?
          if current_user.plan_id.present?
            flash[:error] = "Your account has been deactivated, please email us at support@zenmaid.com to resolve this issue."
            redirect_to user_root_path unless params[:action] == "show"
          else
            redirect_to billing_path unless (params[:action] == "billing" or params[:action] == "subscribe_plan")
          end
        end
      end
    end
    
    def after_sign_up_path_for(resource)
      edit_user_registration_path
    end
    
    def after_update_path_for(resource)
      if params[:custom_fields_page]
        if params[:custom_fields_type] == 'customer'
          customer_custom_fields_path
        elsif params[:custom_fields_type] == 'appointment'
          appointment_custom_fields_path
        elsif params[:custom_fields_type] == 'employee'
          employee_custom_fields_path
        elsif params[:custom_fields_type] == 'instruction'
          instruction_custom_fields_path
        end
      elsif params[:edit_statuses]
        edit_statuses_path
      elsif params[:calendar_options_page]
        calendar_options_path
      elsif params[:email_templates_page]
        email_templates_path
      elsif params[:edit_teams_page]
        edit_teams_path
      elsif params[:credit_card_processing_page]
        credit_card_processing_path
      else
        edit_user_registration_path
      end
    end
    
    def resolve_layout
       if ["new", "create", "systems_week_signup", "systems_week_signup_create", "sign_up", "sign_up_create"].include?(params[:action])
         'application-sign-in'
       else
         'application-admin'
       end
    end
end
