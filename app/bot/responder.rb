class Responder
  include Facebook::Messenger
  extend CommonResponses

  def self.respond(psid, payload)
    Bot.deliver(
      { recipient: { id: psid } }.merge(payload),
      access_token: access_token
    )
  end

  def self.access_token
    Rails.application.credentials.page_access_token
  end

  def self.send_no_subscription_cta(service)
    payload = no_subscription_cta(service.username, service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_has_subscription_cta(service, num)
    payload = subscribed_cta(service.cta_options, num)
    respond(service.sender_id, payload)
  end

  def self.send_account_linked_cta(service)
    payload = account_linked_cta(service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_link_account_cta(service)
    payload = link_account_cta(service.sender_id)
    respond(service.sender_id, payload)
  end

  def self.send_renew_token_cta(service)
    payload = renew_token_cta(service.sender_id)
    respond(service.sender_id, payload)
  end

  def self.send_no_community_to_subscribe_cta(service)
    payload =
      no_community_to_subscribe_cta(service.username, service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_communities_to_subscribe_cta(service, list_items)
    payload = communities_to_subscribe_cta(list_items)
    respond(service.sender_id, payload)
  end
end
