shared_examples 'templates' do
  subject { described_class }

  describe '#text_message_template' do
    it 'returns the text message template structure' do
      expected = { message: { text: 'hello world' } }
      expect(subject.text_message_template('hello world')).to eq expected
    end
  end

  describe '#account_link_btn' do
    it 'returns the account_link button structure' do
      expected = { type: 'account_link', url: 'http://a.com' }
      expect(subject.account_link_btn('http://a.com')).to eq expected
    end
  end

  describe '#basic_share_btn' do
    it 'returns the basic share_btn button structure' do
      expect(subject.basic_share_btn).to eq(type: 'element_share')
    end
  end

  describe '#url_btn' do
    it 'returns the url btn structure' do
      expected = {
        type: 'web_url',
        title: 'some-title',
        url: 'http://link.com'
      }
      expect(subject.url_btn('some-title', 'http://link.com')).to eq expected
    end
  end

  describe '#webview_btn' do
    let(:expected) do
      {
        title: 'abc',
        type: 'web_url',
        url: 'http://a.com',
        webview_height_ratio: 'tall',
        messenger_extensions: 'true',
        fallback_url: 'http://a.com'
      }
    end

    context 'height is given' do
      it 'returns the url btn structure with the given height' do
        expect(subject.webview_btn('abc', 'http://a.com', 'tall')).to eq expected
      end
    end

    context 'height is not given' do
      it 'returns the url btn structure with height set to compact' do
        expect(subject.webview_btn('abc', 'http://a.com'))
          .to eq expected.merge(webview_height_ratio: 'compact')
      end
    end
  end

  describe '#postback_btn' do
    it 'returns the postback btn structure' do
      expected = {
        title: 'post back',
        type: 'postback',
        payload: 'I need this'
      }

      expect(subject.postback_btn('post back', 'I need this')).to eq expected
    end
  end

  describe '#button_template' do
    it 'returns the button template structure' do
      expected = {
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: 'with one button',
              buttons: %w[some buttons]
            }
          }
        }
      }

      expect(
        subject.button_template('with one button', %w[some buttons])
      ).to eq expected
    end
  end

  describe '#quick_reply_option' do
    it 'returns the quick reply options structure' do
      expected = {
        content_type: 'text',
        payload: 'send back',
        title: 'reply quick',
        image_url: 'http://img.png'
      }

      expect(
        subject.quick_reply_option('send back', 'reply quick', 'http://img.png')
      ).to eq expected
    end
  end

  describe '#quick_reply_template' do
    it 'returns the quick reply template structure' do
      expected = { message: { text: 'halla', quick_replies: %w[opt ions] } }
      expect(subject.quick_reply_template('halla', %w[opt ions])).to eq expected
    end
  end

  describe '#generic_template' do
    it 'returns the generic_template structure' do
      expected = {
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'generic',
              elements: %w[some elements]
            }
          }
        }
      }

      expect(subject.generic_template(%w[some elements])).to eq expected
    end
  end

  describe '#list_template' do
    context 'when style is given' do
      it 'returns the list template structure with the given style' do
        expected = {
          message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: 'list',
                top_element_style: 'top',
                elements: %w[some elements]
              }
            }
          }
        }

        expect(subject.list_template(%w[some elements], 'top')).to eq expected
      end
    end

    context 'when style is not given' do
      it 'returns the list template structure with the compact style' do
        expected = {
          message: {
            attachment: {
              type: 'template',
              payload: {
                template_type: 'list',
                top_element_style: 'compact',
                elements: %w[some elements]
              }
            }
          }
        }

        expect(subject.list_template(%w[some elements])).to eq expected
      end
    end
  end

  describe 'list_template_item' do
    it 'returns the structure for a list template item' do
      expected = {
        title: 'Numero uno',
        subtitle: 'ofu',
        image_url: 'pishu.jpg',
        buttons: %w[one-button-oo]
      }

      expect(subject.list_template_item(
               'Numero uno', 'ofu', 'pishu.jpg', %w[one-button-oo]
             )).to eq expected
    end
  end

  describe 'media_template' do
    it 'returns the structure of the media template with the given element' do
      expected = {
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'media',
              elements: %w[some elements]
            }
          }
        }
      }

      expect(subject.media_template(%w[some elements])).to eq expected
    end
  end

  describe 'media_template_element_item' do
    context 'attachment_id is present' do
      it 'returns the media element with attachment_id set' do
        expected = {
          'media_type': 'video',
          'attachment_id': 546,
          buttons: ['some-btn']
        }

        expect(subject
          .media_template_element_item(
            'video',
            ['some-btn'],
            attachment_id: 546
          )).to eq expected
      end
    end

    context 'url is present' do
      it 'returns the media element with quick_reply set' do
        link = 'fb-approved-link'
        expected = {
          'media_type': 'video',
          'url': link,
          buttons: ['some-btn']
        }

        expect(
          subject.media_template_element_item('video', ['some-btn'], url: link)
        ).to eq expected
      end
    end

    # TODO: not good! consider some mini validation
    context 'url and attachment_id are both present' do
      it 'returns the media element with both set' do
        link = 'fb-approved-link'
        expected = {
          media_type: 'video',
          url: link,
          attachment_id: 546,
          buttons: ['some-btn']
        }

        expect(
          subject.media_template_element_item(
            'video',
            ['some-btn'],
            url: link,
            attachment_id: 546
          )
        ).to eq expected
      end
    end
  end

  describe '#attachment_template' do
    context 'template type is given' do
      it 'returns base structure for attachment_templates with given type' do
        expected = {
          message: { attachment: { type: 'type-2', payload: 'bigly' } }
        }
        expect(subject.attachment_template('bigly', 'type-2')).to eq expected
      end
    end

    context 'template type is not given' do
      it 'returns base structure for attachment_templates default template' do
        expected = {
          message: { attachment: { type: 'template', payload: 'bigly' } }
        }
        expect(subject.attachment_template('bigly')).to eq expected
      end
    end
  end
end
