class Client
  include Facebook::Messenger

  def self.respond(psid, payload)
    Bot.deliver(
      { recipient: { id: psid } }.merge(payload),
      access_token: access_token
    )
  end

  def self.access_token
    Rails.application.credentials.page_access_token
  end
end
