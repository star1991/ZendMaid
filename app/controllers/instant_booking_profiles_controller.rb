class InstantBookingProfilesController < ApplicationController
  
  layout 'application-admin'
  
  before_filter :profile_owner, :only => [:edit, :update]
  
  def edit
    @instant_booking_profile = InstantBookingProfile.find_by_id(params[:id])
    
    render 'edit'
  end
  
  def update
   @instant_booking_profile = InstantBookingProfile.find(params[:id])

    respond_to do |format|
      if @instant_booking_profile.update_attributes(params[:instant_booking_profile])
        format.html { redirect_to edit_instant_booking_profile_path(@instant_booking_profile), notice: 'Your profile was successfully updated!' }
        format.json { head :no_content }
      else

        flash.now[:error] = "Please review the errors below"
        format.html { render action: "edit" }
        format.json { render json: @instant_booking_profile.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def embedded_assets
    @instant_booking_profile = InstantBookingProfile.find_by_id(params[:id])
    
    respond_to do |format|
      format.css { render 'embedded_assets' }
    end
  end
  
  protected
  
  def profile_owner
    if current_user.blank? || current_user != InstantBookingProfile.find_by_id(params[:id]).user
      redirect_to user_root_path, notice: "Please sign in"
    end
  end
  
end
