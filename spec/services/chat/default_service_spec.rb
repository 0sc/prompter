require 'rails_helper'
require 'support/omniauth'
require 'services/chat/quick_reply'

RSpec.describe Chat::DefaultService, type: :service do
  it_behaves_like 'quick_reply'

  let(:message) { double }
  subject { Chat::DefaultService.new(message) }
  let(:user) { subject.user }

  before do
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
  end

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => 100)
    allow(message).to receive(:messaging).and_return('message' => {})
  end

  describe '#handle' do
    context 'message is quick_reply' do
      before(:each) do
        allow(message).to receive(:messaging)
          .and_return('message' => { 'quick_reply' => '' })
      end

      it 'calls the handle quick reply method' do
        expect(subject).to receive(:handle_quick_reply)
        subject.handle
      end
    end

    context 'message is chat' do
      describe 'user has no subscriptions' do
        it 'sends the no subscribe cta' do
          expect(Responder).to receive(:send_no_subscription_cta).with(subject)
          subject.handle
        end
      end

      describe 'user has subscriptions' do
        it 'sends the has subscriptions cta' do
          subject.user.member_profile.add_community(create(:community))
          expect(Responder)
            .to receive(:send_has_subscription_cta).with(subject, 1)
          subject.handle
        end
      end
    end
  end

  describe '#cta_options' do
    context '@cta_options variable is set' do
      it 'returns the content of the variables' do
        subject.instance_variable_set(:@cta_options, ['yam'])
        expect(subject.cta_options).to eq ['yam']
      end
    end

    context '@cta_options variable is not set' do
      it 'returns the default_cta_options' do
        expect(subject.cta_options)
          .to eq ChatService.new(message).default_cta_options
      end
    end
  end
end
