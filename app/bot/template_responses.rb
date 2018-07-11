module TemplateResponses
  include Utils

  def communities_to_manage_cta(items)
    elements = items.map { |item| generic_template_item_attr(item) }
    generic_template(elements)
  end

  def communities_to_subscribe_cta(items)
    elements = items.map { |item| build_list_template_item(item) }
    list_template(elements)
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
