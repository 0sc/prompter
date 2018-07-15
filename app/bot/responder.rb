class Responder < Client
  extend TemplateResponses

  @trans_base = 'chat.responses.'.freeze

  def self.send_no_subscription_cta(service)
    msg = t('no_subscription.msg', username: service.username)
    payload = build_default_cta(msg, service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_has_subscription_cta(service, num)
    msg = t('subscribed.msg', num: num)
    payload = build_default_cta(msg, service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_account_linked_cta(service)
    msg = t('account_linked.msg')
    payload = build_default_cta(msg, service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_community_not_found_cta(service)
    msg = t('community_not_found.msg')
    payload = build_default_cta(msg, service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_link_account_cta(service)
    msg = t('link_account.msg')
    btn = build_account_link_btn(service.sender_id)
    payload = button_template(msg, [btn])
    respond(service.sender_id, payload)
  end

  def self.send_renew_token_cta(service)
    msg = t('renew_token.msg')
    btn = build_account_link_btn(service.sender_id)
    payload = button_template(msg, [btn])
    respond(service.sender_id, payload)
  end

  def self.send_no_community_to_subscribe_cta(service)
    msg = t('no_community.msg',
            username: service.username,
            link: Utils::HOST_URL)
    payload = build_default_cta(msg, service.cta_options)
    respond(service.sender_id, payload)
  end

  def self.send_single_community_to_subscribe_cta(service, item)
    btn = postback_btn(t('subscribe_community.cta'), item[:postback])
    payload = button_template(item[:title], [btn])
    respond(service.sender_id, payload)
  end

  def self.send_communities_to_subscribe_cta(service, list_items)
    payload = communities_to_subscribe_cta(list_items)
    respond(service.sender_id, payload)
  end

  def self.send_subscribe_communities_cta(service)
    msg = t('subscribe_communities.msg')
    btn = webview_btn(
      t('subscribe_communities.cta'), fullpath('/communities'), 'tall'
    )
    payload = button_template(msg, [btn])
    respond(service.sender_id, payload)
  end

  def self.send_subscribed_to_community_cta(service, profile)
    msg = t('subscribed_to_community.msg',
            name: profile.community_name,
            categories: profile.subscribed_feed_category_summary)
    btn = manage_subscription_webview_btn(profile.id)
    payload = button_template(msg, [btn])
    respond(service.sender_id, payload)
  end

  def self.send_communities_to_manage_cta(service, items)
    payload = communities_to_manage_cta(items)
    respond(service.sender_id, payload)
  end

  def self.send_welcome_note(service)
    msg = t('get_started.welcome')
    payload = text_message_template(msg)
    respond(service.sender_id, payload)
  end

  def self.send_get_started_cta(service, add_manage_cta = false)
    msg = t('get_started.cta')
    msg += t('get_started.cta_manage') if add_manage_cta
    payload = build_default_cta(msg, service.cta_options)
    respond(service.sender_id, payload)
  end
end
