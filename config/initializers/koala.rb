Koala.configure do |config|
  config.app_id = ENV.fetch('FACEBOOK_KEY')
  config.app_secret = ENV.fetch('FACEBOOK_SECRET')
end
