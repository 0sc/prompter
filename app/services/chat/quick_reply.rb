module Chat::QuickReply
  FIND_COMMUNITIES = 'find-communities'.freeze
  SUBSCRIBE_COMMUNITIES = 'subscribe-communities'.freeze
  MANAGE_COMMUNITIES = 'manage-communities'.freeze

  def handle_quick_reply
    case quick_reply_payload
    when FIND_COMMUNITIES
      handle_find_community
    when SUBSCRIBE_COMMUNITIES
      handle_subscribe_communities
    when MANAGE_COMMUNITIES
      handle_manage_communities
    else
      handle_msg_reply
    end
  end

  private

  def handle_find_community
    return Responder.send_link_account_cta(self) unless user.account_linked?
    return Responder.send_renew_token_cta(self) if user.token_expired?

    # user token to find all users communities that are subscribed and present to them to choose from
  end

  def handle_subscribe_communities
    return Responder.send_link_account_cta(self) unless user.account_linked?
    return Responder.send_renew_token_cta(self) if user.token_expired?

    # opens a webview for them to use the webapp
  end

  def handle_manage_communities
    return Responder.send_no_subscription_cta unless user.subscribed?

    # lists users subscribed community with option
  end

  def quick_reply_payload
    message.messaging.dig('message', 'quick_reply', 'payload')
  end
end
