class PayrollsController < ApplicationController

  before_filter :payroll_owner
 
  layout 'application-admin'
  
  def show
    @payroll = Payroll.find(params[:id])
  end
  
  def create
    current_user.payrolls.find_by_draft(true).try(:destroy)
    
    @payroll = current_user.payrolls.build(:start_date => Time.zone.parse(params[:date_range][:from]).beginning_of_day, :end_date => Time.zone.parse(params[:date_range][:to]).end_of_day)

    if @payroll.populate_draft_payroll
      redirect_to @payroll
    else
      redirect_to payrolls_path, :notice =>  "There are no available appointments for the selected date range. Some appointments may already be linked to approved payrolls"
    end
    
  end
  
  def index
    @draft_payroll = current_user.payrolls.find_by_draft(true)
    
    @payrolls = current_user.payrolls.order('payroll_number DESC')

    if params[:date_range].present?
      @to = Time.zone.parse(params[:date_range][:to]).end_of_day
      @from = Time.zone.parse(params[:date_range][:from]).beginning_of_day
      @payrolls = @payrolls.where(:end_date => @from..@to).where(:draft => false)
    end
  end
  
  def destroy
    @payroll = current_user.payrolls.find(params[:id]).destroy
    
    redirect_to payrolls_path, :notice => "Payroll ##{@payroll.payroll_number} has been successfully destroyed"
  end
  
  def approve
    @payroll = current_user.payrolls.find(params[:id])
    
    @payroll.approve!
    
    redirect_to @payroll, :notice => "Payroll has been approved!"
  end
  
  def recalculate
    @payroll = current_user.payrolls.find(params[:id])
    
    if not @payroll.draft?
      redirect_to @payroll, :notice => "Payroll has already been approved!"
    else
      @payroll.appointments.update_all(:payroll_id => nil)
      
      # Payroll total pay is not refreshed after destroy callbacks on payroll entries,
      # leading it to be erroneously set to 0 and reported unchanged when payroll is recalculated
      # Using a delete here bypasses the callbacks and restores desired behavior (shouldn't lead to orphaned assignment records within the context of recalculate)
      PayrollEntry.delete_all(:payroll_id => @payroll.id)
      @payroll.payroll_entries_count = 0
      
      @payroll.populate_draft_payroll
      @payroll.out_of_date = false
      redirect_to @payroll, :notice => "Payroll has been recalculated"
    end
    
  end

  def report
    
    @payroll = current_user.payrolls.find(params[:id])
    
    @payroll.payroll_entries.each do |entry|
      entry.calculate_totals_for_report
    end
    
    respond_to do |format|
      format.pdf do
        render :pdf => "payroll_report_#{@payroll.payroll_number}",
               :layout => 'layouts/application-pdf.pdf',
               :margin => {
                 :top => 20,
                 :bottom => 25,
                 :left => 20,
                 :right => 20
               }
      end
    end    
    
  end

  def payroll_owner
    if current_user.blank? || (params[:id].present? && current_user != Payroll.find_by_id(params[:id]).user)
      redirect_to user_root_path, notice: "Please sign into the account which owns this payroll record to edit it"
    end
  end
  
end
