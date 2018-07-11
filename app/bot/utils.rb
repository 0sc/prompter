module Utils
  HOST_URL = ENV.fetch('HOST_URL')

  include Templates

  def t(key, **args)
    key = @trans_base + key
    I18n.t(key, args)
  end

  def fullpath(link)
    HOST_URL + link
  end

  def build_account_link_btn(psid)
    url = fullpath("/users/#{psid}/account_link")
    account_link_btn(url)
  end

  def build_default_cta(msg, opts)
    options = opts.map do |opt|
      quick_reply_option(opt, t("quick_reply.#{opt.underscore}"), cta_img(opt))
    end

    quick_reply_template(msg, options)
  end

  def manage_subscription_webview_btn(profile_id)
    title = I18n.t('chat.responses.btns.manage')
    link = fullpath("/community_member_profiles/#{profile_id}/edit")
    url_btn(title, link)
  end

  def cta_img(key)
    fullpath("/img/#{key}.png")
  end
end
