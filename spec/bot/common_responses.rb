shared_examples 'common responses' do
  subject { described_class }
  let(:opts) { [Chat::QuickReply::FIND_COMMUNITIES] }
  let(:base) { CommonResponses::TRANS_BASE }
  let(:host) { 'https://some-host.com' }

  before { stub_const('CommonResponses::HOST_URL', host) }

  describe '.no_subscription_cta' do
    it 'returns the payload for no subscription response' do
      msg = I18n.t("#{base}.no_subscription.msg", username: 'Sam')
      payload = expected_payload(msg)
      expect(subject.no_subscription_cta('Sam', opts)).to eq payload
    end
  end

  describe '.account_linked_cta' do
    it 'returns the payload for the account link cta' do
      msg = I18n.t("#{base}.account_linked.msg")
      payload = expected_payload(msg)
      expect(subject.account_linked_cta(opts)).to eq payload
    end
  end

  describe '.subscribed_cta' do
    it 'returns the payload for the subscribed cta' do
      msg = I18n.t("#{base}.subscribed.msg", num: 10)
      payload = expected_payload(msg)
      expect(subject.subscribed_cta(opts, 10)).to eq payload
    end
  end

  describe '.no_subscription_cta' do
    it 'returns the payload for no subscription response' do
      msg = I18n.t("#{base}.no_community.msg", username: 'Sam', link: host)
      payload = expected_payload(msg)
      expect(subject.no_community_to_subscribe_cta('Sam', opts)).to eq payload
    end
  end

  describe '.community_not_found_cta' do
    it 'returns the payload for no subscription response' do
      msg = I18n.t("#{base}.community_not_found.msg")
      payload = expected_payload(msg)
      expect(subject.community_not_found_cta(opts)).to eq payload
    end
  end

  shared_examples 'button template' do |mtd|
    it 'returns the button template' do
      msg = I18n.t("#{base}.#{mtd}.msg")

      payload = {
        template_type: 'button',
        text: msg,
        buttons: btns
      }
      expected = {
        message: { attachment: { type: 'template', payload: payload } }
      }

      expect(result).to eq expected
    end
  end

  shared_examples 'link account cta' do |mtd|
    include_examples 'button template', mtd do
      let(:btns) do
        url = "#{host}/users/12345/account_link"
        [{ type: 'account_link', url: url }]
      end
      let(:result) { subject.send("#{mtd}_cta", 12_345) }
    end
  end

  describe '.link_account_cta' do
    it_behaves_like 'link account cta', :link_account
  end

  describe '.renew_token_cta' do
    it_behaves_like 'link account cta', :renew_token
  end

  describe '.subscribe_communities_cta' do
    it_behaves_like 'button template', :subscribe_communities do
      let(:btns) do
        [
          {
            title: I18n.t("#{base}.subscribe_communities.cta"),
            type: 'web_url',
            url: "#{host}/communities",
            webview_height_ratio: 'tall',
            messenger_extensions: 'true',
            fallback_url: "#{host}/communities"
          }
        ]
      end
      let(:result) { subject.subscribe_communities_cta }
    end
  end

  describe '.communities_to_subscribe_cta' do
    it 'returns the list template payload to subscribe the given communities' do
      item = {
        title: 'my-community-name',
        image: 'some-item-image.jpg',
        postback: 'heres-what-you-get-back'
      }
      payload = {
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
      }
      expect(subject.communities_to_subscribe_cta([item])).to eq payload
    end
  end

  describe 'subscribed_to_community_cta' do
    it 'returns the manage community webview button template' do
      payload = {
        template_type: 'button',
        text: I18n.t("#{base}.subscribed_to_community.msg", name: 'comm-name'),
        buttons: [{
          title: I18n.t("#{base}.btns.manage"),
          type: 'web_url',
          url: "#{host}/community_member_profiles/69/edit",
          webview_height_ratio: 'compact',
          messenger_extensions: 'true',
          fallback_url: "#{host}/community_member_profiles/69/edit"
        }]
      }
      expected = {
        message: { attachment: { type: 'template', payload: payload } }
      }

      expect(subject.subscribed_to_community_cta(69, 'comm-name'))
        .to eq expected
    end
  end

  describe 'single_community_to_subscribe_cta' do
    it 'returns the manage community webview button template' do
      item = {
        title: 'community-name',
        postback: 'some-postback-1',
        image: 'some-image'
      }

      payload = {
        template_type: 'button',
        text: item[:title],
        buttons: [{
          title: I18n.t("#{base}.subscribe_community.cta"),
          type: 'postback',
          payload: item[:postback]
        }]
      }
      expected = {
        message: { attachment: { type: 'template', payload: payload } }
      }

      expect(subject.single_community_to_subscribe_cta(item))
        .to eq expected
    end
  end

  def expected_payload(msg)
    {
      message: {
        text: msg,
        quick_replies: expected_options
      }
    }
  end

  def expected_options(options = opts)
    options.map do |o|
      {
        content_type: 'text',
        payload: o,
        title: I18n.t("#{base}.quick_reply.#{o.underscore}"),
        image_url: CommonResponses::QUICK_REPLY_IMAGES[o]
      }
    end
  end
end
