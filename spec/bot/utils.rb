shared_examples 'utils' do
  subject { described_class }
  let(:host) { 'https://fiddle.fie' }
  let!(:bckup) { described_class.instance_variable_get(:@trans_base) }

  before do
    stub_const('Utils::HOST_URL', host)
    subject.instance_variable_set(:@trans_base, 'chat.responses.')
  end

  after { subject.instance_variable_set(:@trans_base, bckup) }

  describe 't' do
    it 'returns the translation for the given key and args' do
      subject.instance_variable_set(:@trans_base, 'chat.responses.')
      expect(subject.t('subscribed.msg', num: 3))
        .to eq I18n.t('chat.responses.subscribed.msg', num: 3)
    end
  end

  describe 'fullpath' do
    it 'prepends the host path to the given string' do
      expect(subject.fullpath('fom')).to eq host + 'fom'
    end
  end

  describe 'build_account_link_btn' do
    it 'returns teh account_link button prepared with the given id' do
      expected = {
        type: 'account_link',
        url: host + '/users/123/account_link'
      }

      expect(subject.build_account_link_btn(123)).to eq expected
    end
  end

  describe 'build_default_cta' do
    it 'returns the quick reply template for the default options' do
      opts = %w[find-communities finetune-prompts]
      msg = 'Behold the default'
      expected = {
        message:   {
          text: 'Behold the default',
          quick_replies:     [
            {
              content_type: 'text',
              payload: 'find-communities',
              title: 'Find a community',
              image_url: 'https://fiddle.fie/img/find-communities.png'
            },
            {
              content_type: 'text',
              payload: 'finetune-prompts',
              title: 'Fine-tune your prompts',
              image_url: 'https://fiddle.fie/img/finetune-prompts.png'
            }
          ]
        }
      }

      expect(subject.build_default_cta(msg, opts)).to eq expected
    end
  end

  describe 'manage_subscription_webview_btn' do
    it 'returns a webview template tuned to the manage subscription url' do
      expected = {
        fallback_url: 'https://fiddle.fie/community_member_profiles/76/edit',
        messenger_extensions: 'true',
        title: 'Fine tune',
        type: 'web_url',
        url: 'https://fiddle.fie/community_member_profiles/76/edit',
        webview_height_ratio: 'compact'
      }
      expect(subject.manage_subscription_webview_btn(76)).to eq expected
    end
  end

  describe 'cta_img' do
    it 'return the full url to the png img with the given name' do
      expected = host + '/img/dope.png'
      expect(subject.cta_img('dope')).to eq expected
    end
  end
end
