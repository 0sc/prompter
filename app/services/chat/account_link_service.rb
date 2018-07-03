class Chat::AccountLinkService < ChatService
  def handle
    ::Responder.send_account_linked_cta(self)
  end
end
