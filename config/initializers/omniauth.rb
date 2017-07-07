Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :mailchimp, ENV['MAILCHIMP_KEY'], ENV['MAILCHIMP_SECRET']
  else
    provider :mailchimp, ENV['MAILCHIMP_KEY'], ENV['MAILCHIMP_SECRET'], {:client_options => {:ssl => {:verify => false}}}
  end
end