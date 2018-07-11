class Responder < Client
  extend CommonResponses
  @trans_base = 'chat.responses.'.freeze

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

  def self.send_community_not_found_cta(service)
    payload = community_not_found_cta(service.cta_options)
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

  def self.send_single_community_to_subscribe_cta(service, item)
    payload = single_community_to_subscribe_cta(item)
    respond(service.sender_id, payload)
  end

  def self.send_communities_to_subscribe_cta(service, list_items)
    payload = communities_to_subscribe_cta(list_items)
    respond(service.sender_id, payload)
  end

  def self.send_subscribe_communities_cta(service)
    payload = subscribe_communities_cta
    respond(service.sender_id, payload)
  end

  def self.send_subscribed_to_community_cta(service, profile)
    payload = subscribed_to_community_cta(
      profile.id,
      profile.community_name,
      profile.subscribed_feed_category_summary
    )
    respond(service.sender_id, payload)
  end

  def self.send_communities_to_manage_cta(service, items)
    payload = communities_to_manage_cta(items)
    respond(service.sender_id, payload)
  end
end
