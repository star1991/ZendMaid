class MailchimpSubscriber

  def self.auth_settings
    if Rails.env.production?
      api_key = ENV['MAILCHIMP_KEY']
      api_secret = ENV['MAILCHIMP_SECRET']
    else
      api_key, api_secret = "157192077720", "00362d8cdb7dc1f7e2f878d8c837679c"
    end
    return [api_key, api_secret]
  end

  # create a mailchimp list
  def self.create_new_list(user, list_name = nil)
    auth = user.auth

    success = true
    data = new_list_default_params(user, list_name)

    ret = nil
    begin
      ret = HTTParty.post("https://#{auth.dc}.api.mailchimp.com/3.0/lists", :body => data.to_json, :headers => headers(auth), :verify => !Rails.env.development? )
    rescue
      success = false
    end
    return success, ret
  end

  # fetch all mailchimp lists
  def self.lists(user_id)
    user = User.where(:id => user_id).last
    auth = Auth.where(:user_id => user_id, :provider => 'mailchimp').last

    success = true

    if auth
      ret = nil
      begin
        ret = HTTParty.get("https://#{auth.dc}.api.mailchimp.com/3.0/lists", :headers => headers(auth), :verify => !Rails.env.development? )
        ret = ret["lists"]
      rescue
        success = false
      end
    else
      success = false
      ret = []
    end
    return success, ret
  end

  # subscribe multiple emails
  def self.subscribe_batch(user, list, batch = [])
    auth = user.auth

    success = true
    if auth.present? && batch.present?
      params = {
        :apikey => "#{auth.oauth_token}-#{auth.dc}",
        :id => list,
        :batch => batch,
        :double_optin => false,
        :update_existing => false
      }

      begin
        ret = HTTParty.post("https://#{auth.dc}.api.mailchimp.com/2.0/lists/batch-subscribe", body: params.to_json)
      rescue
        success = false
      end
    else
      success = false
    end
    success
  end

  def self.headers(auth)
    {'Authorization' => "apikey #{auth.oauth_token}-#{auth.dc}"}
  end

  def self.new_list_default_params(user, list_name = nil)
    data = {
      "name" => "#{list_name}",
      "contact" => {
        "company" => user.user_profile.company_name,
        "address1" => "default",
        "address2" => "",
        "city" => "default",
        "state" => "default",
        "zip" => "default",
        "country" => "default",
        "phone" => ""
      },
      "permission_reminder" => "",
      "use_archive_bar" => false,
      "campaign_defaults" => {
        "from_name" => user.user_profile.company_name,
        "from_email" => user.user_profile.company_email,
        "subject" => "",
        "language" => "english"
      },
      "notify_on_subscribe" => user.user_profile.company_email,
      "notify_on_unsubscribe" => user.user_profile.company_email,
      "email_type_option" => true,
      "visibility" => "pub"
    }
    return data
  end
end