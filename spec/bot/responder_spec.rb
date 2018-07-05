require 'rails_helper'
require 'bot/common_responses'

RSpec.describe Responder do
  it_behaves_like 'common responses'
  let(:service) { double }
  let(:base) { CommonResponses::TRANS_BASE }
  let(:bot) { Facebook::Messenger::Bot }
  let(:host) { 'https://some-host.com' }

  before do
    allow(Responder).to receive(:access_token).and_return(123)
    stub_const('CommonResponses::HOST_URL', host)
  end

  before(:each) do
    allow(service).to receive(:sender_id).and_return(789)
    allow(service).to receive(:cta_options).and_return(['manage-community'])
  end

  describe '.send_no_subscription_cta' do
    before(:each) { allow(service).to receive(:username).and_return('Jerry') }

    it 'delivers the no_subscription_cta payload' do
      msg = I18n.t("#{base}.no_subscription.msg", username: 'Jerry')
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_no_subscription_cta(service)
    end
  end

  describe '.send_no_community_to_subscribe_cta' do
    before(:each) { allow(service).to receive(:username).and_return('Jerry') }

    it 'delivers the no_subscription_cta payload' do
      msg = I18n.t("#{base}.no_community.msg", username: 'Jerry', link: host)
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_no_community_to_subscribe_cta(service)
    end
  end

  describe '.send_has_subscription_cta' do
    it 'delivers the has subscribed_cta payload' do
      msg = I18n.t("#{base}.subscribed.msg", num: 456)
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_has_subscription_cta(service, 456)
    end
  end

  describe '.send_account_linked_cta' do
    it 'delivers the account_linked_cta payload' do
      msg = I18n.t("#{base}.account_linked.msg")
      payload = expected_payload(service.sender_id, build_quick_reply_cta(msg))

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_account_linked_cta(service)
    end
  end

  describe '.send_community_not_found_cta' do
    it 'delivers the account_linked_cta payload' do
      msg = I18n.t("#{base}.community_not_found.msg")
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
              text: I18n.t("#{base}.link_account.msg"),
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
    it 'delivers the link_account_cta payload' do
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: I18n.t("#{base}.renew_token.msg"),
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
    it 'delivers the link_account_cta payload' do
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: I18n.t("#{base}.subscribe_communities.msg"),
              buttons: [{
                title: I18n.t("#{base}.subscribe_communities.cta"),
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
    it 'delivers the link_account_cta payload' do
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
                title: I18n.t("#{base}.subscribe_community.cta"),
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
    it 'delivers the link_account_cta payload' do
      item = {
        title: 'my-community-name',
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
                  subtitle: 'See all our colors',
                  image_url: item[:image],
                  buttons: [
                    {
                      title: I18n.t("#{base}.subscribe_community.cta"),
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
      community = create(:community)
      name = community.name
      payload = expected_payload(
        789,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: I18n.t("#{base}.subscribed_to_community.msg", name: name),
              buttons: [{
                title: I18n.t("#{base}.btns.manage"),
                type: 'web_url',
                url: "#{host}/#{community.id}",
                webview_height_ratio: 'compact',
                messenger_extensions: 'true',
                fallback_url: "#{host}/#{community.id}"
              }]
            }
          }
        }
      )

      expect(bot).to receive(:deliver).with(payload, access_token: 123)

      Responder.send_subscribed_to_community_cta(service, community)
    end
  end

  def build_quick_reply_cta(msg)
    {
      message: {
        text: msg,
        quick_replies: [{
          content_type: 'text',
          payload: 'manage-community',
          title: I18n.t('chat.responses.common.quick_reply.manage_community'),
          image_url: CommonResponses::QUICK_REPLY_IMAGES['manage-community']
        }]
      }
    }
  end

  def expected_payload(psid, payload)
    { recipient: { id: psid } }.merge(payload)
  end
end
