shared_examples 'common responses' do
  subject { described_class }
  let(:opts) { [Chat::QuickReply::FIND_COMMUNITY] }
  let(:base) { CommonResponses::TRANS_BASE }

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

  shared_examples 'link account cta' do |mtd|
    it 'returns the payload for the link account cta' do
      msg = I18n.t("#{base}.#{mtd}.msg")
      stub_const('CommonResponses::HOST_URL', 'https://some-host.come')
      url = 'https://some-host.come/users/12345/account_link'
      payload = {
        template_type: 'button',
        text: msg,
        buttons: [
          { type: 'account_link', url: url }
        ]
      }
      expected = {
        message: { attachment: { type: 'template', payload: payload } }
      }

      expect(subject.send("#{mtd}_cta", 12_345)).to eq expected
    end
  end

  describe '.link_account_cta' do
    it_behaves_like 'link account cta', :link_account
  end

  describe '.renew_token_cta' do
    it_behaves_like 'link account cta', :renew_token
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
