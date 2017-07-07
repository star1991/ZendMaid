class AssignmentsController < ApplicationController
  
  layout 'application-admin'
  
  
  def unlink_from_payroll
    @assignment = Assignment.find(params[:id])
    
    payroll_entry = @assignment.payroll_entry
    @assignment.unlink_from_payroll_entry
    
    redirect_to payroll_entry
  end
  
  def edit_fixed_rate
    @assignment = Assignment.find(params[:id])
    
    render 'edit_fixed_rate'
  end
  
  def update_fixed_rate
    @assignment = Assignment.find(params[:id])
    
    if @assignment.update_attributes(params[:assignment])
      render 'reload_window'
    else
      render 'edit_fixed_rate'
    end
  end
  
  def edit_revenue_share
    @assignment = Assignment.find(params[:id])
    @appointment = @assignment.appointment
    @payroll_entry = @assignment.payroll_entry

    
    render 'edit_revenue_share'
  end
  
  def update_revenue_share
    @assignment = Assignment.find(params[:id])
    
    @appointment = @assignment.appointment
    @appointment.allow_conflicts = true

    @payroll_entry = @assignment.payroll_entry    
    
    if @appointment.update_attributes(params[:appointment])
      render 'reload_window'
    else
      render 'edit_revenue_share'
    end    
  end

  def edit_hourly
    @assignment = Assignment.find(params[:id])
    @payroll_entry = @assignment.payroll_entry
    
    render 'edit_hourly'
  end
  
  def update_hourly
    @assignment = Assignment.find(params[:id])


    if @assignment.update_attributes(params[:assignment])
      render 'reload_window'
    else
      render 'edit_hourly'
    end    
  end

end
