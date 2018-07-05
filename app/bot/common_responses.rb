module CommonResponses
  TRANS_BASE = 'chat.responses.common'.freeze
  HOST_URL = ENV.fetch('HOST_URL', 'https://193d4a2a.ngrok.io')
  QUICK_REPLY_IMAGES = {
    ::Chat::QuickReply::FIND_COMMUNITIES => 'https://agoge.nz/Images/search-03.png',
    ::Chat::QuickReply::SUBSCRIBE_COMMUNITIES => 'https://png.icons8.com/ios/1600/add.png'
  }.freeze

  def no_subscription_cta(username, opts)
    msg = I18n.t("#{TRANS_BASE}.no_subscription.msg", username: username)
    default_cta(msg, opts)
  end

  def account_linked_cta(opts)
    msg = I18n.t("#{TRANS_BASE}.account_linked.msg")
    default_cta(msg, opts)
  end

  def subscribed_cta(opts, num)
    msg = I18n.t("#{TRANS_BASE}.subscribed.msg", num: num)
    default_cta(msg, opts)
  end

  def no_community_to_subscribe_cta(username, opts)
    msg = I18n.t("#{TRANS_BASE}.no_community.msg",
                 username: username,
                 link: HOST_URL)
    default_cta(msg, opts)
  end

  def community_not_found_cta(opts)
    msg = I18n.t("#{TRANS_BASE}.community_not_found.msg")
    default_cta(msg, opts)
  end

  def link_account_cta(sender_id)
    msg = I18n.t("#{TRANS_BASE}.link_account.msg")
    payload = link_account_btn(msg, sender_id)

    { message: { attachment: { type: 'template', payload: payload } } }
  end

  def renew_token_cta(sender_id)
    msg = I18n.t("#{TRANS_BASE}.renew_token.msg")
    payload = link_account_btn(msg, sender_id)

    { message: { attachment: { type: 'template', payload: payload } } }
  end

  def communities_to_subscribe_cta(items)
    elements = items.map { |item| list_template_item_attr(item) }
    payload = {
      template_type: 'list',
      top_element_style: 'compact',
      elements: elements
    }
    { message: { attachment: { type: 'template', payload: payload } } }
  end

  def subscribe_communities_cta
    payload = {
      template_type: 'button',
      text: I18n.t("#{TRANS_BASE}.subscribe_communities.msg"),
      buttons: [subscribe_webview_btn]
    }

    { message: { attachment: { type: 'template', payload: payload } } }
  end

#====

  def default_cta(msg, opts)
    options = default_cta_options(opts)
    { message: { text: msg, quick_replies: options } }
  end

  def default_cta_options(opts)
    opts.map do |opt|
      {
        content_type: 'text',
        payload: opt,
        title: I18n.t("#{TRANS_BASE}.quick_reply.#{opt.underscore}"),
        image_url: QUICK_REPLY_IMAGES[opt]
      }
    end
  end

  def list_template_item_attr(item)
    {
      title: item[:title],
      subtitle: 'See all our colors',
      image_url: item[:image],
      buttons: [
        {
          title: I18n.t("#{TRANS_BASE}.subscribe_community.cta"),
          type: 'postback',
          payload: item[:postback]
        }
      ]
    }
  end

  def link_account_btn(msg, sender_id)
    url = "#{HOST_URL}/users/#{sender_id}/account_link"
    {
      template_type: 'button',
      text: msg,
      buttons: [
        { type: 'account_link', url: url }
      ]
    }
  end

  def subscribe_webview_btn
    {
      title: I18n.t("#{TRANS_BASE}.subscribe_communities.cta"),
      type: 'web_url',
      url: "#{HOST_URL}/communities",
      webview_height_ratio: 'tall',
      messenger_extensions: 'true',
      fallback_url: "#{HOST_URL}/communities"
    }
  end
end
