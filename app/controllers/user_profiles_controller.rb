class UserProfilesController < ApplicationController
  
  layout 'application-admin'
  
  
  def iframe_test
    render 'user_profiles/iframe_test_page'
  end
  
  def edit
    @user_profile = current_user.user_profile
  end
  
  def update
    @user_profile = current_user.user_profile
    
    if @user_profile.update_attributes(params[:user_profile])
      redirect_to edit_user_profile_path(@user_profile), :notice => "Company Information was updated!"
    else
      flash.now[:error] = "Oops! Please review the errors below."
      render 'edit'
    end
  end
  
end
