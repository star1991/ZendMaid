class PayrollEntriesController < ApplicationController
  
  before_filter :payroll_entry_owner
  
  layout 'application-admin'
  
  def show
    @payroll_entry = PayrollEntry.find(params[:id])
    
    @payroll = @payroll_entry.payroll
    
    @entries_by_date = @payroll_entry.group_by_date_and_calculate_totals
  end
  
  def destroy
    @payroll_entry = current_user.payroll_entries.find(params[:id])
    
    @payroll_entry.destroy
    redirect_to @payroll_entry.payroll, :notice => "Entry for #{@payroll_entry.full_name} has been removed"
  end
  
  def update
    @payroll_entry = current_user.payroll_entries.find(params[:id])
    
    respond_to do |format|
      if @payroll_entry.update_attributes(params[:payroll_entry])
        format.json { respond_with_bip(@payroll_entry) }
      else
        format.json { respond_with_bip(@payroll_entry) }
      end
    end   
  end

  def payroll_entry_owner
    if current_user.blank? || (params[:id].present? && current_user != PayrollEntry.find_by_id(params[:id]).user)
      redirect_to user_root_path, notice: "Please sign into the account which owns this payroll entry record to edit it"
    end
  end
  
end
