=begin
{
  "attachment_id": "1767475553328236" <= find
  "attachment_id": "1767476273328164" <= manage
  "attachment_id": "1767476809994777" <= subscribe
}
=end


module CommonResponses
  QUICK_REPLY_IMAGES = {
    # ::Chat::QuickReply::FIND_COMMUNITIES => HOST_URL + '/img/find/png',
    # ::Chat::QuickReply::SUBSCRIBE_COMMUNITIES => HOST_URL + '/img/Subscribe/png',
    # ::Chat::QuickReply::MANAGE_COMMUNITIES => HOST_URL + '/img/manage/png'
  }.freeze

include Utils

  def no_subscription_cta(username, opts)
    msg = t('no_subscription.msg', username: username)
    default_cta(msg, opts)
  end

  def account_linked_cta(opts)
    msg = t('account_linked.msg')
    default_cta(msg, opts)
  end

  def subscribed_cta(opts, num)
    msg = t('subscribed.msg', num: num)
    default_cta(msg, opts)
  end

  def no_community_to_subscribe_cta(username, opts)
    msg = t('no_community.msg', username: username, link: HOST_URL)
    default_cta(msg, opts)
  end

  def community_not_found_cta(opts)
    msg = t('community_not_found.msg')
    default_cta(msg, opts)
  end

  def link_account_cta(sender_id)
    msg = t('link_account.msg')
    btn = build_account_link_btn(sender_id)

    button_template(msg, [btn])
  end

  def renew_token_cta(sender_id)
    msg = t('renew_token.msg')
    btn = build_account_link_btn(sender_id)

    button_template(msg, [btn])
  end

  def communities_to_manage_cta(items)
    elements = items.map { |item| generic_template_item_attr(item) }
    generic_template(elements)
  end

  def communities_to_subscribe_cta(items)
    elements = items.map { |item| build_list_template_item(item) }
    list_template(elements)
  end

  def single_community_to_subscribe_cta(item)
    btn = postback_btn(t('subscribe_community.cta'), item[:postback])
    button_template(item[:title], [btn])
  end

  def subscribe_communities_cta
    msg = t('subscribe_communities.msg')
    btn =
      url_btn(t('subscribe_communities.cta'), fullpath('/communities'), 'tall')
    button_template(msg, [btn])
  end

  def subscribed_to_community_cta(id, name, categories)
    msg = t('subscribed_to_community.msg', name: name, categories: categories)
    btn = manage_subscription_webview_btn(id)
    button_template(msg, [btn])
  end

#====

  def default_cta(msg, opts)
    options = opts.map do |opt|
      quick_reply_option(opt, t("quick_reply.#{opt.underscore}"), cta_img(opt))
    end

    quick_reply_template(msg, options)
  end

  def cta_img(key)
  end

  def generic_template_item_attr(item)
    {
      title: item[:title],
      subtitle: item[:subtitle],
      image_url: item[:image],
      default_action: {
        type: 'web_url',
        url: fullpath(item[:url]),
        webview_height_ratio: 'tall',
        messenger_extensions: 'true',
        fallback_url: fullpath(item[:url])
      },
      buttons: [
        {
          type: 'web_url',
          url: fullpath(item[:url]),
          webview_height_ratio: 'tall',
          messenger_extensions: 'true',
          fallback_url: fullpath(item[:url]),
          title: t('manage_community.cta')
        }
      ]
    }
  end

  def build_list_template_item(item)
    btn = postback_btn(t('subscribe_community.cta'), item[:postback])
    list_template_item(item[:title], item[:subtitle], item[:image], [btn])
  end
end
