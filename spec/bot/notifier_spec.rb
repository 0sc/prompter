require 'rails_helper'
require 'bot/templates'
require 'bot/utils'

RSpec.describe Notifier do
  let(:bot) { Facebook::Messenger::Bot }
  let(:psid) { 12_345 }
  let(:host) { 'https://some-host.com' }

  before do
    allow(Client).to receive(:access_token).and_return(123)
    stub_const('Utils::HOST_URL', host)
  end

  it_behaves_like 'templates'
  it_behaves_like 'utils'

  describe '.send_community_feed_notice' do
    it 'delivers the community_feed_notice payload' do
      link = 'https://why.cloaking.not/work'
      feed = 'Hey I still get detected when I am in Ninja cloaking mode. Why?'
      name = 'My super community'
      category = 'ninjas'
      payload_one = expected_payload(
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t('community_feed.notice.msg',
                      category: category,
                      name: name,
                      feed: feed),
              buttons: [
                {
                  title: t('community_feed.notice.cta'),
                  type: 'web_url',
                  url: link
                }
              ]
            }
          }
        }
      )

      payload_two = expected_payload(
        message: {
          text: t('community_feed.feedback.msg', category: category),
          quick_replies: [
            {
              content_type: 'text',
              payload: 'FEEDBACK-OK',
              title: t('community_feed.feedback.right'),
              image_url: host + '/img/right.png'
            },
            {
              content_type: 'text',
              payload: 'FEEDBACK-WRONG',
              title: t('community_feed.feedback.wrong'),
              image_url: host + '/img/wrong.png'
            }
          ]
        }
      )

      expect(bot).to receive(:deliver)
        .ordered.once.with(payload_one, access_token: 123)
      # expect(bot).to receive(:deliver)
      # .ordered.once.with(payload_two, access_token: 123)

      Notifier.send_community_feed_notice(
        psid: psid,
        name: name,
        category: category,
        feed: feed,
        link: link
      )
    end
  end

  describe '.send_community_feed_feedback' do
    it 'delivers the feedback payload' do
      category = 'ninjas'
      payload = expected_payload(
        message: {
          text: t('community_feed.feedback.msg', category: category),
          quick_replies: [
            {
              content_type: 'text',
              payload: 'FEEDBACK-OK',
              title: t('community_feed.feedback.right'),
              image_url: host + '/img/right.png'
            },
            {
              content_type: 'text',
              payload: 'FEEDBACK-WRONG',
              title: t('community_feed.feedback.wrong'),
              image_url: host + '/img/wrong.png'
            }
          ]
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_community_feed_feedback(psid: psid, category: category)
    end
  end

  describe '.send_community_added_notice' do
    it 'delivers the community added payload' do
      name = 'Dojo'
      link = 'https://come.to/the/dojo'

      payload = expected_payload(
        message: {
          text: t('community_added.notice', name: name, link: link)
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_community_added_notice(psid: psid, name: name, link: link)
    end
  end

  describe '.send_community_type_changed_notice' do
    it 'delivers the community type changed payload' do
      pid = 1234
      url = Utils::HOST_URL + "/community_member_profiles/#{pid}/edit"
      info = 'cloaking, shuriken and 4 others'
      n = 'My super community'
      t = 'ninjas'

      payload = expected_payload(
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t('community_type_changed.notice', type: t, name: n, info: info),
              buttons: [
                {
                  title: I18n.t('chat.responses.btns.manage'),
                  type: 'web_url',
                  url: url,
                  webview_height_ratio: 'compact',
                  messenger_extensions: 'true',
                  fallback_url: url
                }
              ]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_community_type_changed_notice(
        psid: psid,
        pid: pid,
        name: n,
        type: t,
        info: info
      )
    end
  end

  describe '.send_community_removed_notice' do
    it 'delivers the community removed payload' do
      name = 'Dojo'
      payload = expected_payload(
        message: {
          text: t('community_removed.notice', name: name)
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_community_removed_notice(psid: psid, name: name)
    end
  end

  describe '.send_community_profile_deleted_notice' do
    it 'delivers the community profile deleted payload' do
      name = 'Dojo'
      payload = expected_payload(
        message: {
          text: t('community_profile_deleted.notice', name: name)
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_community_profile_deleted_notice(psid: psid, name: name)
    end
  end

  describe '.send_community_profile_updated_notice' do
    it 'delivers the community profile upddated payload' do
      name = 'Dojo'
      info = 'cloaking, taijutsu and 3 other'
      payload = expected_payload(
        message: {
          text: t('community_profile_updated.notice', name: name, info: info)
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_community_profile_updated_notice(
        psid: psid, name: name, info: info
      )
    end
  end

  describe '.send_access_token_expiring_notice' do
    it 'delivers the access token expiring payload' do
      url = Utils::HOST_URL + "/users/#{psid}/account_link"
      payload = expected_payload(
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t('access_token_expiring.notice', num: 3),
              buttons: [{ type: 'account_link', url: url }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_access_token_expiring_notice(psid: psid, num_admin_comms: 3)
    end
  end

  describe '.send_access_token_expired_notice' do
    it 'delivers the access token expired payload' do
      url = Utils::HOST_URL + "/users/#{psid}/account_link"
      payload = expected_payload(
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t('access_token_expired.notice', num: 3),
              buttons: [{ type: 'account_link', url: url }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_access_token_expired_notice(psid: psid, num_admin_comms: 3)
    end
  end

  describe '.send_qrcode_notice' do
    it 'delivers the qrcode ready payload' do
      payload = expected_payload(
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'media',
              elements: [
                media_type: 'image',
                attachment_id: 321,
                buttons: [{ type: 'element_share' }]
              ]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)
      Notifier.send_qrcode_notice(psid: psid, attachment_id: 321)
    end
  end

  def expected_payload(payload)
    { recipient: { id: psid } }.merge(payload)
  end

  def t(key, **args)
    key = 'chat.notifications.' + key
    I18n.t(key, args)
  end
end
