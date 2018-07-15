class Chat::QuickReplyService < ChatService
  def handle
    payload = quick_reply_payload
    case payload
    when 'FEEDBACK-WRONG'
      p 'Got quick reply wrong feed category'
    when 'FEEDBACK-OK'
      p 'Got quick reply right feed category'
    else
      super(payload)
    end
  end

  private

  def quick_reply_payload
    message.messaging.dig('message', 'quick_reply', 'payload')
  end
end
