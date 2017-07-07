class AdminsController < ApplicationController
  
  layout 'application-admin'
  
  before_filter :authenticate_admin!
  
  def show
    if current_employee.blank?
      flash.now[:notice] = "Please sign in as a user and then visit www.zenmaid.com/admins/show"
      authenticate_employee!
    end
    
    @users = User.order("users.id ASC")
  end
  
  def user_sign_in
    user = User.find_by_id(params[:id])
    sign_in user.employees.find_by_owner(true)
    
    if params[:destination] == "billing"
      redirect_to billing_path
    elsif params[:destination] == 'import'
      redirect_to import_customers_page_path
    else
      redirect_to user_root_path
    end
  end
  
  def manage_user_account
    @user = User.find_by_id(params[:user_id])
    sign_in @user.employees.find_by_owner(true)
  end

  def user_summary
    @user = User.find(params[:user_id])
  end
  
end
