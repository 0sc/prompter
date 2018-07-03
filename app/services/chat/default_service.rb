class Chat::DefaultService < ChatService
  include Chat::QuickReply

  def handle
    quick_reply? ? handle_quick_reply : handle_msg_reply
  end

  def handle_msg_reply
    if user.subscriptions?
      handle_has_subscription
    else
      handle_no_subscription
    end
  end

  def cta_options
    default_cta_options
  end

  private

  def handle_has_subscription
    num_subscribed = user.subscription_count
    Responder.send_has_subscription_cta(self, num_subscribed)
  end

  def handle_no_subscription
    Responder.send_no_subscription_cta(self)
  end

  def quick_reply?
    message.messaging.dig('message').key? 'quick_reply'
  end
end
