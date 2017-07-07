class AuthController < ApplicationController

  before_filter :authenticate_user!

  def authenticate
    redirect_to generate_redirect_url('mailchimp')
  end

  #- Handle callback response
  def callback
    auth_hash = request.env['omniauth.auth']

    if request.env['omniauth.params'].length > 0
      params = request.env['omniauth.params']
    end

    response_params = {:user_id => params["user_id"] }

    auth = create_or_update_auth(auth_hash, response_params)

    flash[:notice] = "You are now connected to #{auth_hash.provider.capitalize}"

    case auth_hash.provider
    when 'mailchimp'
      redirect_to mailchimp_setting_path and return
    end
    redirect_to root_path and return
  end

  def failure
    flash[:notice] = 'Oops! We could not authorize you'
    
    redirect_to root_path and return
  end

  def create_mailchimp_list
    unless params[:mailchimp_list][:name].present?
      flash[:error] = "Oops! please choose a name for new mailchimp list."
      redirect_to mailchimp_setting_path and return
    end

    success, list = MailchimpSubscriber.create_new_list(current_user.id, params[:mailchimp_list][:name])

    if success
      flash[:notice] = "A list #{params[:mailchimp_list][:name]} has been created in your mailchimp account."
    else
      flash[:error] = "Opps!, some issue with conneting  with mailchimp, please try after some time."
    end
    
    redirect_to mailchimp_setting_path and return
  end

  private

  def create_or_update_auth(auth_hash, response_params)
    auth_user = Auth.where(:provider => auth_hash.provider, :user_id => response_params[:user_id]).last

    auth_user = auth_user ? auth_user : Auth.new
    auth_user.oauth_token = auth_hash.credentials.token
    auth_user.oauth_secret = auth_hash.credentials.secret || 'none'
    auth_user.provider_id = auth_hash.uid
    auth_user.provider = auth_hash.provider
    auth_user.name = auth_hash.info.first_name
    auth_user.user_id = current_user.id
    auth_user.dc = "#{auth_hash['extra']['metadata']['dc']}"
    auth_user.save!
    auth_user
  end

  def generate_redirect_url(provider)
    request_params = "/auth/#{provider}?user_id=#{@current_user.id}"
  end
end