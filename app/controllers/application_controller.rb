class ApplicationController < ActionController::Base
  protect_from_forgery

  include SubdomainHelper
  include ApplicationHelper


  before_filter :miniprofiler
  before_filter :onboarding
  before_filter :secure_app_with_ssl

  # load user from currently signed in employee, hack for adding multi-user login functionality to existing app
  def current_user
    @current_user ||= current_employee.try(:user)
  end
  
  def authenticate_user!(opts={})
    opts[:scope] = :employee
    warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
  end

  protected

  
  def secure_app_with_ssl
    #TODO: Fix kludge to deal with instant booking form
    if request.subdomain == 'app' and request.protocol != 'https://' and params[:controller] != "instant_bookings" and params[:controller] != "instant_booking_profiles"
      redirect_to :protocol => 'https://'
    end
  end

  def check_embedded
    if params[:embed].present?
      'embedded_instant_booking'
    else
      'instant_booking_subdomain'
    end
  end

  def miniprofiler
    if current_user.try(:id) == 2
      Rack::MiniProfiler.authorize_request
    end
  end

  def onboarding
    # Currently only redirect to onboarding if user hasn't finished the user_info page
    if current_user.present? && !current_admin.present? && current_user.onboarding_page < 2 && params[:controller] != "onboarding" && request.format != "text/javascript"
      redirect_to current_onboarding_page
    end
  end

end
