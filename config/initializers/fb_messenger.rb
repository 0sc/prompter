class CredentialProvider < Facebook::Messenger::Configuration::Providers::Base
  def valid_verify_token?(verify_token)
    verify_token == creds_source.webhook_verify_token
  end

  def app_secret_for(_page_id)
    creds_source.facebook_secret
  end

  def access_token_for(_page_recipient)
    creds_source.facebook_page_access_token
  end

  private

  def creds_source
    Rails.application.credentials
  end
end

Facebook::Messenger.configure do |config|
  config.provider = CredentialProvider.new
end
