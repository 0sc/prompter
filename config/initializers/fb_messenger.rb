class CredentialProvider < Facebook::Messenger::Configuration::Providers::Base
  def valid_verify_token?(verify_token)
    verify_token == creds_source.webhook_verify_token
  end

  def app_secret_for(_page_id)
    ENV.fetch('FACEBOOK_SECRET')
  end

  def access_token_for(_page_recipient)
    ENV.fetch('PAGE_ACCESS_TOKEN')
  end

  private

  def creds_source
    Rails.application.credentials
  end
end

class MessengerProfileSetup
  def bulk
    set_get_started
      .merge(set_whitelist_domains)
      .merge(set_greeting_text)
      .merge(set_persistent_menu)
  end

  def set_get_started
    { get_started: { payload: Chat::PostbackService::GET_STARTED } }
  end

  def set_whitelist_domains
    { whitelisted_domains: [ENV.fetch('HOST_URL')] }
  end

  def set_greeting_text
    msg = <<-TXT.strip_heredoc
      Hey {{user_first_name}}! Want an engaging community?
      I'll prompt you to chime in on just the kind of posts you care about.
      Interested?
    TXT
    { greeting: [{ locale: 'default', text: msg }] }
  end

  def set_persistent_menu
    actions = %w[find_communities add_communities finetune_prompts]
    cta = actions.map do |action|
      {
        title: action.tr('_', ' ').titleize,
        type: 'postback',
        payload: "ChatService::#{action.upcase}".constantize
      }
    end

    {
      persistent_menu: [{
        locale: 'default',
        composer_input_disabled: true,
        call_to_actions: cta
      }]
    }
  end
end

unless Rails.env.test?
  access_token = ENV.fetch('PAGE_ACCESS_TOKEN')

  Facebook::Messenger.configure do |config|
    config.provider = CredentialProvider.new
  end

  payload = MessengerProfileSetup.new.bulk
  Facebook::Messenger::Profile.set(payload, access_token: access_token)
end
