class InstantBookingsController < ApplicationController

  before_filter :instant_booking_owner
  
  layout :check_embedded_booking
  
  def new
    if params[:profile_id].present?
      @instant_booking_profile = InstantBookingProfile.find_by_id(params[:profile_id])
    else
      @instant_booking_profile = InstantBookingProfile.find_by_subdomain(request.subdomain)
    end
    
    if @instant_booking_profile.present?
      @user = @instant_booking_profile.user
      
      @instant_booking = @user.instant_bookings.build
      address = @instant_booking.build_address
      
      pass_gon_parameters
      @instant_booking.build_all_missing_instant_booking_items(@user)
      
      render 'new'
    else
      redirect_to root_url(:host => request.domain)
    end
  end
  
  # POST or PUT /instant_booking/
  def create
    @instant_booking = InstantBooking.new(params[:instant_booking])
    @instant_booking_profile = InstantBookingProfile.find_by_id(params[:profile_id])
    @user = @instant_booking_profile.user
    
    @instant_booking.price = params[:estimated_price]
    
    respond_to do |format|
      if @instant_booking.save
        
        InstantBookingsMailer.view_instant_booking(@instant_booking).deliver
        InstantBookingsMailer.notify_client_of_booking(@instant_booking).deliver
        
        format.html { redirect_to preview_instant_booking_path(@instant_booking, :embed => params[:embed]), notice: 'Thank you! Your appointment was successfully booked! We will contact you shortly to confirm' }
        format.json { head :no_content }
      else
        # Don't render fields for all appointments a customer has ever booked when showing errors
        pass_gon_parameters
        @instant_booking.build_all_missing_instant_booking_items(@user)

        flash.now[:error] = "Oops! Something went wrong. Please correct the errors below and try again."
        format.html { render action: "new" }
        format.json { render json: @instant_booking.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def show
    @instant_booking = InstantBooking.find_by_id(params[:id])
    @user = @instant_booking.user
    @appointment = @instant_booking.appointment
    
  end

  def preview
    @instant_booking = InstantBooking.find_by_id(params[:id])
    @user = @instant_booking.user
  end
  
  def index
   
    if params[:filter] == 'all'
      @instant_bookings = current_user.instant_bookings.order('instant_bookings.start_time DESC')
    else
      @instant_bookings = current_user.instant_bookings.pending.order('instant_bookings.start_time DESC')
    end
    
  end
  

  def destroy
    @instant_booking = InstantBooking.find(params[:id])
    @instant_booking.destroy

    respond_to do |format|
      format.html { redirect_to instant_bookings_path, notice: "Booking has been deleted" }
      format.json { head :no_content }
    end
  end
  
  def pass_gon_parameters
    gon.appointment_fields_map = Hash[@user.instant_booking_fields.map { |field| [field.id, field.value_names.invert]}]
    gon.pricing_tables = @user.pricing_tables.map {|table| {:custom_field_ids => table.custom_field_ids, :pricing_table => table.pricing_table}}
    gon.service_type_map = Hash[@user.service_types.map {|service_type| [service_type.id, service_type.instant_booking_fields.map(&:id)]}]
    gon.service_type_base_prices = Hash[@user.service_types.map {|service_type| [service_type.id, service_type.base_price]}]
    gon.skip_days = @instant_booking_profile.skip_days
  end
  
  def check_embedded_booking
    if params[:action] == 'index' or params[:action] == 'show'
      'application-admin'
    elsif params[:embed].present?
      'embedded_instant_booking'
    else
      'instant_booking_subdomain'
    end
  end  

  def instant_booking_owner
    case action_name
    when 'new', 'create', 'preview'
      # Do nothing
    else
      if current_user.blank? || (params[:id].present? && current_user != InstantBooking.find_by_id(params[:id]).try(:user))
        redirect_to user_root_path, :notice => "Please sign in"
      elsif !current_user.active?
        flash[:error] = "Your account has been deactivated, please email us at support@zenmaid.com to resolve this issue."
        redirect_to user_root_path
      end
    end
  end
  
end
