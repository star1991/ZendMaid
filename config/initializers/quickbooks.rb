

if Rails.env.development?
  Quickbooks.sandbox_mode = true
  QB_KEY = "lvprdGR4NoMD2NjU5zZf7b6uL2quWE"
  QB_SECRET = "6H9smA08ngJ8AcAtsENztgQhjdwIe2iJR38vFKBA"
else
  QB_KEY = ENV['QB_KEY']
  QB_SECRET = ENV['QB_SECRET']
end


$qb_oauth_consumer = OAuth::Consumer.new(QB_KEY, QB_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})
