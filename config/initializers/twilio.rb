Rails.configuration.twilio = {
  :from => ENV["TWILIO_NUMBER"],
  :auth_token => ENV["TWILIO_AUTH_TOKEN"],
  :account_sid => ENV["TWILIO_ACCOUNT_SID"]
}
