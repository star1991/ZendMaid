ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "zenmaid.com",
  :user_name            => "lindseyaadevs@gmail.com",
  :password             => "fourhourweek",
  :authentication       => "plain",
  :enable_starttls_auto => true 
} if Rails.env.development?

Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?

ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['SENDGRID_USERNAME'],
  :password       => ENV['SENDGRID_PASSWORD'],
  :domain         => 'heroku.com',
  :enable_starttls_auto => true
} if Rails.env.production?

ActionMailer::Base.default_url_options[:host] = "zenmaid.com"
