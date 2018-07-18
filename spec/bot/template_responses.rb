shared_examples 'template responses' do
  subject { described_class }
  let(:host) { 'https://some-host.com' }

  before { stub_const('Utils::HOST_URL', host) }

  describe '.communities_to_subscribe_cta' do
    it 'returns the list template payload to subscribe the given communities' do
      item = {
        title: 'my-community-name',
        subtitle: '10 categories',
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
      }
      expect(subject.communities_to_subscribe_cta([item])).to eq payload
    end
  end

  describe '.communities_to_manage_cta' do
    it 'returns the generic template payload to manage the given communities' do
      item = {
        title: 'my-community-name',
        image: 'some-item-image.jpg',
        subtitle: 'Ruby, Golang and Elixer',
        url: '/community_member_profiles/100/edit'
      }

      payload = {
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
                      title: 'Fine-tune',
                      messenger_extensions: 'true',
                      fallback_url: host + item[:url]
                    }
                  ]
                }
              ]
            }
          }
        }
      }
      expect(subject.communities_to_manage_cta([item])).to eq payload
    end
  end
end
