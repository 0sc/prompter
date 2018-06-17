Koala.configure do |config|
  config.app_id = Rails.application.credentials.facebook_key
  config.app_secret = Rails.application.credentials.facebook_secret
end
