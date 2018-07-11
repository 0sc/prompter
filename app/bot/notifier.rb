class Notifier < Client
  include Facebook::Messenger
  extend Utils

  @trans_base = 'chat.notifications.'.freeze

  def self.send_community_feed_notice(psid:, name:, category:, feed:, link:)
    cta = t('community_feed.notice.cta')
    btn = url_btn(cta, link, 'full')
    msg =
      t('community_feed.notice.msg', category: category, name: name, feed: feed)
    payload = button_template(msg, [btn])
    respond(psid, payload)
    # TODO: show typing icon
    send_community_feed_feedback(psid: psid, category: category)
  end

  def self.send_community_feed_feedback(psid:, category:)
    feedback_msg = t('community_feed.feedback.msg', category: category)

    # TODO: hookup to quick_reply
    right = t('community_feed.feedback.right')
    wrong = t('community_feed.feedback.wrong')
    options = [
      quick_reply_option('FEEDBACK', right, cta_img('right')),
      quick_reply_option('FEEDBACK', wrong, cta_img('wrong'))
    ]

    feedback = quick_reply_template(feedback_msg, options)
    respond(psid, feedback)
  end

  def self.send_community_added_notice(psid:, name:, link:)
    msg = t('community_added.notice', name: name, link: link)
    payload = text_message_template(msg)
    respond(psid, payload)
  end

  def self.send_community_type_changed_notice(psid:, pid:, name:, type:, info:)
    msg = t('community_type_changed.notice', type: type, name: name, info: info)
    btn = manage_subscription_webview_btn(pid)
    payload = button_template(msg, [btn])
    respond(psid, payload)
  end

  def self.send_community_removed_notice(psid:, name:)
    msg = t('community_removed.notice', name: name)
    payload = text_message_template(msg)
    respond(psid, payload)
  end

  def self.send_community_profile_deleted_notice(psid:, name:)
    msg = t('community_profile_deleted.notice', name: name)
    payload = text_message_template(msg)
    respond(psid, payload)
  end

  def self.send_community_profile_updated_notice(psid:, info:, name:)
    msg = t('community_profile_updated.notice', name: name, info: info)
    payload = text_message_template(msg)
    respond(psid, payload)
  end

  def self.send_access_token_expiring_notice(psid:, num_admin_comms:)
    msg = t('access_token_expiring.notice', num: num_admin_comms)
    btn = build_account_link_btn(psid)
    payload = button_template(msg, [btn])
    respond(psid, payload)
  end

  def self.send_access_token_expired_notice(psid:, num_admin_comms:)
    msg = t('access_token_expired.notice', num: num_admin_comms)
    btn = build_account_link_btn(psid)
    payload = button_template(msg, [btn])
    respond(psid, payload)
  end
end
