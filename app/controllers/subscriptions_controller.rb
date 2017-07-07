class SubscriptionsController < ApplicationController

  before_filter :authenticate_user!
  
  layout "application-admin"
  
  def new
  end

  def create
    @employee = Employee.find_by_id(params[:employee_id])
    @subscription = @employee.predefined_obligations.build(params[:subscription])

    respond_to do |format|
      if @subscription.save
        format.js
        format.html { redirect_to @subscription.subscriptionable, notice: 'Unavailability was successfully created.' }
        format.json { render json: @employee, status: :created, location: @employee }
      else
        format.js
        format.html { redirect_to @employee, notice: 'Unable to create unavailability.' }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @user = current_user
    @subscription = @user.subscriptions.find_by_id(params[:id])
    @subscription.inactivate_on = Time.zone.now.strftime('%d/%m/%Y')
    
    @customer = @subscription.subscriptionable
    @appointment = @subscription.appointment_prototype
  end

  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

    respond_to do |format|

      format.html { redirect_to user_root_path,  :notice => "Appointment(s) were successfully deleted!"}
      format.json { head :no_content }
    end
  end
  

  def update
    #Actually submit form for subscription and update appointment as nested association
    @subscription = Appointment.find_by_id(params[:id]).subscription
    
    respond_to do |format|
      if @subscription.update_attributes(params[:subscription])
        @appointment = @subscription.appointments.select {|appointment| appointment.id == params[:id].to_i}[0]
        @user = current_user
        
        format.html { render action: 'edit', notice: 'Appointment information was successfully updated.' }
        format.json { head :no_content }
      else
        # Making sure to load the appointment with the validation errors and avoiding a query
        @appointment = @subscription.appointments.select {|appointment| appointment.id == params[:id].to_i}[0]
        @user = current_user
        
        format.html { render action: "edit" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def inactivate
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    
    @subscription.disable(Time.zone.parse(params[:subscription][:inactivate_on]))
    @subscription.save
    
    redirect_to edit_subscription_path(@subscription), :notice => "Recurring service was successfully inactivated!"
  end
  
  def adjust
    @old_subscription = current_user.subscriptions.find_by_id(params[:id])  
    @old_prototype = @old_subscription.appointment_prototype    
    
    pivot_appointment = Appointment.find_by_id(params[:subscription][:inactivate_on])
    @new_subscription = @old_subscription.dup
    @new_subscription.assign_attributes(params[:subscription])
   
    @old_subscription.disable(pivot_appointment.start_time - 1.day)
    @old_subscription.save! 
        
    # Note: subscription will create prototype appointment from this seed in its before_create callback
    @seed_appointment = @old_prototype.dup_with_repeatable_associations
    @seed_appointment.start_time = pivot_appointment.start_time
    @seed_appointment.end_time = pivot_appointment.end_time
    
    @new_subscription.appointments << @seed_appointment
    @new_subscription.save
    
    redirect_to edit_subscription_path(@new_subscription), :notice => "Recurring service was successfully adjusted!"
  end
  
  def edit_status
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    
    new_status_id = params[:subscription][:appointments_attributes]["0"][:status_id]
    from_date = params[:subscription][:edit_on].present? ? Time.zone.parse(params[:subscription][:edit_on]) : Time.zone.now.beginning_of_day
    
    @subscription.appointments.where(["appointments.start_time > ? OR appointments.use_as_prototype = ?", from_date, true]).update_all(:status_id => new_status_id)
    
    redirect_to edit_subscription_path(@subscription), :notice => "Status for recurring service was successfully adjusted!"
  end
  
end
