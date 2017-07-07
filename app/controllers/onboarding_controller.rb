class OnboardingController < ApplicationController
  include ApplicationHelper
  
  before_filter :authenticate_user!

  layout 'application-sign-in'

  def user_info
    # Set current onboarding page to this page if visiting from another
    if current_user.onboarding_page != 1
      current_user.onboarding_page = 1
      current_user.save
    end

    @user_profile = current_user.user_profile
  end


  def save_user_info
    @user_profile = current_user.user_profile

    if @user_profile.update_attributes(params[:user_profile])
      
      current_user.company_name = @user_profile.company_name
      current_user.phone_number = @user_profile.company_phone_number
      current_user.onboarding_page = 2
      current_user.save

      owner_employee = current_user.employees.find_by_owner(true)
      if @user_profile.full_name.present?
        parsed_name = parse_name(@user_profile.full_name)
        owner_employee.first_name = parsed_name[:first_name]
        owner_employee.last_name = parsed_name[:last_name]
      end
      owner_employee.phone_number = current_user.phone_number
      owner_employee.save

      redirect_to appointments_path
    else
      flash.now[:error] = "Oops! Please correct the errors below to continue"
      render :action => 'user_info'
    end
  end

  def customer_templates
    # Set current onboarding page to this page if visiting from another
    if current_user.onboarding_page != 2
      current_user.onboarding_page = 2
      current_user.save
    end
    
    @user = current_user

    email_templates = @user.email_templates.group_by(&:template_type)
    @email_reminder_template = email_templates["Appointment Reminder"].first
    @email_followup_template = email_templates["Appointment Follow-Up"].first
    @email_confirmation_template = email_templates["Appointment Confirmation"].first
    @email_comeback_template = email_templates["Come Back"].first

    @text_reminder_template = @user.text_templates.find_by_template_type("Appointment Reminder")

  end

  def save_customer_templates
    @user = current_user
    @user.assign_attributes(params[:user])
    @user.onboarding_page = 3


    if @user.save
      redirect_to custom_fields_onboarding_path
    else
      flash.now[:error] = "Oops! Please correct the errors below to continue"
      render :action => 'customer_templates'
    end   
  end

  def custom_fields
    @user = current_user

    # Set current onboarding page to this page if visiting from another
    if current_user.onboarding_page != 3
      current_user.onboarding_page = 3
      current_user.save
    end

  end

  def save_custom_fields

  end

  def employee_management
    @user = current_user
    # Set current onboarding page to this page if visiting from another
    if current_user.onboarding_page != 4
      current_user.onboarding_page = 4
      current_user.save
    end

    @work_order_template = @user.email_templates.find_by_template_type("Work Order")
    @text_work_order_template = @user.text_templates.find_by_template_type("Work Order")

  end

  def save_employee_management
    @user = current_user
    #@user.completed_onboarding = true
    @user.onboarding_page = 5

    if @user.update_attributes(params[:user])
      payroll_task = @user.tasks.build
      payroll_task.task = "Run Payroll"
      payroll_task.note = "You can calculate payroll for the most recent pay period in a few minutes by clicking 'Run Payroll' button on the 'Employees' tab (in the top right corner)"
      payroll_task.due_date = Time.zone.now.strftime('%d/%m/%Y')

      payroll_task.set_to_repeat = "true"
      payroll_task.recurrence_rule = params[:user][:payroll_timing]
      payroll_task.save!

      # Delete first task (which probably doesn't follow correct timing)
      payroll_task.task_recurrence.tasks.order("due_date ASC").limit(1)[0].delete

      redirect_to entrance_survey_path
    else
      @work_order_template = @user.email_templates.find_by_template_type("Work Order")
      @text_work_order_template = @user.text_templates.find_by_template_type("Work Order")
      render :action => 'employee_management'      
    end

  end

  def entrance_survey
    @user = current_user
    # Set current onboarding page to this page if visiting from another
    if current_user.onboarding_page != 5
      current_user.onboarding_page = 5
      current_user.save
    end    
    @user_profile = current_user.user_profile
    @user_profile.entrance_survey = true

  end

  def save_entrance_survey

    @user_profile = current_user.user_profile

    if @user_profile.update_attributes(params[:user_profile])
      current_user.completed_onboarding = true
      current_user.save
      
      LeadsMailer.notify_of_onboarding_completion(current_user).deliver
      redirect_to appointments_path, :notice => "You have successfully completed your account setup!"
    else
      flash.now[:error] = "Oops! Please fill in the information below to continue"
      render :action => 'entrance_survey'
    end
  end

  def instant_booking_pitch

  end

  def exit_survey
    @user = current_user
    @user_profile = current_user.user_profile

    @user_profile.recommendation = 10
  end

  def save_exit_survey
    @user_profile = current_user.user_profile
    @user_profile.exit_survey = true

    if @user_profile.update_attributes(params[:user_profile])
      if current_user.cancel_subscription
        current_user.active = false
        current_user.save

        # notify support regarding unsubscribe
        LeadsMailer.notify_of_exit_survey(current_user).deliver
      else
        flash.now[:error] = "Oops! An unexpected error occured, please try to submit the form again in a moment"
      end
    else
      flash.now[:error] = "Just a moment! Please fill in the information below to continue."
    end
    render :action => 'exit_survey'
  end
end
