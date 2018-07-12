class Chat::QuickReplyService < ChatService
  def handle
    payload = quick_reply_payload
    case payload
    when 'some-custom-thing'
      p 'here'
    when 'another-custom-thing'
      p 'here'
    else
      super(payload)
    end
  end

  private

  def quick_reply_payload
    message.messaging.dig('message', 'quick_reply', 'payload')
  end
end
