require 'rails_helper'
require 'bot/template_responses'
require 'bot/templates'
require 'bot/utils'

RSpec.describe Responder do
  it_behaves_like 'template responses'
  it_behaves_like 'templates'
  it_behaves_like 'utils'

  let(:service) { double }
  let(:bot) { Facebook::Messenger::Bot }
  let(:host) { 'https://some-host.com' }

  before do
    allow(Responder).to receive(:access_token).and_return(123)
    stub_const('Utils::HOST_URL', host)
  end

  before(:each) do
    allow(service).to receive(:sender_id).and_return(789)
    allow(service).to receive(:cta_options).and_return(['manage-communities'])
  end

  describe '.send_no_subscription_cta' do
    before(:each) { allow(service).to receive(:username).and_return('Jerry') }

    it 'delivers the no_subscription_cta payload' do
      msg = t('no_subscription.msg', username: 'Jerry')
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_no_subscription_cta(service)
    end
  end

  describe '.send_no_community_to_subscribe_cta' do
    before(:each) { allow(service).to receive(:username).and_return('Jerry') }

    it 'delivers the no_subscription_cta payload' do
      msg = t('no_community.msg', username: 'Jerry', link: host)
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_no_community_to_subscribe_cta(service)
    end
  end

  describe '.send_has_subscription_cta' do
    it 'delivers the has subscribed_cta payload' do
      msg = t('subscribed.msg', num: 456)
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_has_subscription_cta(service, 456)
    end
  end

  describe '.send_account_linked_cta' do
    it 'delivers the account_linked_cta payload' do
      msg = t('account_linked.msg')
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_account_linked_cta(service)
    end
  end

  describe '.send_community_not_found_cta' do
    it 'delivers the account_linked_cta payload' do
      msg = t('community_not_found.msg')
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_community_not_found_cta(service)
    end
  end

  describe '.send_link_account_cta' do
    it 'delivers the link_account_cta payload' do
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t('link_account.msg'),
              buttons: [{
                type: 'account_link',
                url: "#{host}/users/789/account_link"
              }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_link_account_cta(service)
    end
  end

  describe '.send_renew_token_cta' do
    it 'delivers the renew_token_cta payload' do
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t('renew_token.msg'),
              buttons: [{
                type: 'account_link',
                url: "#{host}/users/789/account_link"
              }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_renew_token_cta(service)
    end
  end

  describe '.send_subscribe_communities_cta' do
    it 'delivers the subscribe_communities_cta payload' do
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t('subscribe_communities.msg'),
              buttons: [{
                title: t('subscribe_communities.cta'),
                type: 'web_url',
                url: "#{host}/communities",
                webview_height_ratio: 'tall',
                messenger_extensions: 'true',
                fallback_url: "#{host}/communities"
              }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_subscribe_communities_cta(service)
    end
  end

  describe '.send_single_community_to_subscribe_cta' do
    it 'delivers the single_community_to_subscribe_cta payload' do
      item = {
        title: 'community-name',
        postback: 'some-postback-1',
        image: 'some-image'
      }
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: item[:title],
              buttons: [{
                title: t('subscribe_community.cta'),
                type: 'postback',
                payload: item[:postback]
              }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_single_community_to_subscribe_cta(service, item)
    end
  end

  describe '.send_communities_to_subscribe_cta' do
    it 'delivers the communities_to_subscribe_cta payload' do
      item = {
        title: 'my-community-name',
        subtitle: '10 categories',
        image: 'some-item-image.jpg',
        postback: 'heres-what-you-get-back'
      }

      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'list',
              top_element_style: 'compact',
              elements: [
                {
                  title: item[:title],
                  subtitle: item[:subtitle],
                  image_url: item[:image],
                  buttons: [
                    {
                      title: t('subscribe_community.cta'),
                      type: 'postback',
                      payload: item[:postback]
                    }
                  ]
                }
              ]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_communities_to_subscribe_cta(service, [item])
    end
  end

  describe '.send_subscribed_to_community_cta' do
    it 'delivers the subscribed to community cta payload' do
      profile = create(:community_member_profile)
      name = profile.community_name
      url = "#{host}/community_member_profiles/#{profile.id}/edit"
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: t(
                'subscribed_to_community.msg',
                name: name,
                categories: profile.subscribed_feed_category_summary
              ),
              buttons: [{
                title: t('btns.manage'),
                type: 'web_url',
                url: url,
                webview_height_ratio: 'compact',
                messenger_extensions: 'true',
                fallback_url: url
              }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_subscribed_to_community_cta(service, profile)
    end
  end

  describe '.send_communities_to_manage_cta' do
    it 'delivers the communities_to_manage_cta payload' do
      item = {
        title: 'my-community-name',
        image: 'some-item-image.jpg',
        subtitle: 'Ruby, Golang and Elixer',
        url: '/community_member_profiles/100/edit'
      }

      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'generic',
              elements: [
                {
                  title: item[:title],
                  subtitle: item[:subtitle],
                  image_url: item[:image],
                  default_action: {
                    type: 'web_url',
                    url: host + item[:url],
                    webview_height_ratio: 'tall',
                    messenger_extensions: 'true',
                    fallback_url: host + item[:url]
                  },
                  buttons: [
                    {
                      type: 'web_url',
                      url: host + item[:url],
                      webview_height_ratio: 'tall',
                      title: 'manage',
                      messenger_extensions: 'true',
                      fallback_url: host + item[:url]
                    }
                  ]
                }
              ]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_communities_to_manage_cta(service, [item])
    end
  end

  describe '.send_welcome_note' do
    it 'delivers the welcome_note payload' do
      payload = expected_payload(
        service.sender_id,
        message: { text: t('get_started.welcome') }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_welcome_note(service)
    end
  end

  describe '.send_get_started_cta' do
    context 'when add_manage_cta is set to true' do
      it 'defaults to false' do
        msg = t('get_started.cta') + t('get_started.cta_manage')
        payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

        expect(bot).to receive(:deliver).with(payload, access_token: 123)

        Responder.send_get_started_cta(service, true)
      end
    end

    context 'when add_manage_cta is set to false' do
      it 'defaults to false' do
        msg = t('get_started.cta')
        payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

        expect(bot).to receive(:deliver).with(payload, access_token: 123)

        Responder.send_get_started_cta(service, false)
      end
    end

    context 'when add_manage_cta is not set' do
      it 'defaults to false' do
        msg = t('get_started.cta')
        payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

        expect(bot).to receive(:deliver).with(payload, access_token: 123)

        Responder.send_get_started_cta(service)
      end
    end
  end

  def build_quick_reply_cta(msg)
    {
      message: {
        text: msg,
        quick_replies: [{
          content_type: 'text',
          payload: 'manage-communities',
          title: I18n.t('chat.responses.quick_reply.manage_communities'),
          image_url: host + '/img/manage-communities.png'
        }]
      }
    }
  end

  def expected_payload(psid, payload)
    { recipient: { id: psid } }.merge(payload)
  end

  def t(key, **args)
    key = 'chat.responses.' + key
    I18n.t(key, args)
  end
end
