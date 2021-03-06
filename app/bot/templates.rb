module Templates
  BTN_TEMPLATE_TEXT_MAX_CHARS = 640
  # TEXT MESSAGE
  def text_message_template(msg)
    { message: { text: msg } }
  end

  # BUTTONS
  def account_link_btn(url)
    { type: 'account_link', url: url }
  end

  def basic_share_btn
    { type: 'element_share' }
  end

  def url_btn(title, url)
    {
      type: 'web_url',
      title: title,
      url: url
    }
  end

  def webview_btn(title, url, height = 'compact')
    url_btn(title, url).merge(
      webview_height_ratio: height,
      messenger_extensions: 'true',
      fallback_url: url
    )
  end

  def postback_btn(title, payload)
    {
      title: title,
      type: 'postback',
      payload: payload
    }
  end

  def button_template(msg, btns)
    payload = {
      template_type: 'button',
      text: msg.truncate(BTN_TEMPLATE_TEXT_MAX_CHARS, separator: ' '),
      buttons: btns
    }
    attachment_template(payload)
  end

  # QUICK REPLIES
  def quick_reply_option(postback, title, image_url)
    {
      content_type: 'text',
      payload: postback,
      title: title,
      image_url: image_url
    }
  end

  def quick_reply_template(msg, options)
    { message: { text: msg, quick_replies: options } }
  end

  # GENERIC TEMPLATE
  def generic_template(elements)
    payload = {
      template_type: 'generic',
      elements: elements
    }
    attachment_template(payload)
  end

  # LIST TEMPLATE
  def list_template(elements, style = 'compact')
    payload = {
      template_type: 'list',
      top_element_style: style,
      elements: elements
    }

    attachment_template(payload)
  end

  def list_template_item(title, subtitle, image, btns)
    {
      title: title,
      subtitle: subtitle,
      image_url: image,
      buttons: btns
    }
  end

  # MEDIA TEMPLATE
  def media_template(elts)
    payload = {
      template_type: 'media',
      elements: elts
    }

    attachment_template(payload)
  end

  def media_template_element_item(type, btns, attachment_id: nil, url: nil)
    item = {
      media_type: type,
      buttons: btns
    }
    item[:attachment_id] = attachment_id if attachment_id
    item[:url] = url if url
    item
  end

  # BASE

  def attachment_template(payload, type = 'template')
    { message: { attachment: { type: type, payload: payload } } }
  end
end
