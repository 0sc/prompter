require 'rails_helper'
require 'support/omniauth'

RSpec.describe Chat::MessageService, type: :service do
  let(:message) { double }
  subject { Chat::MessageService.new(message) }
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
    context 'user has no subscriptions' do
      it 'sends the no subscription cta' do
        expect(Responder).to receive(:send_no_subscription_cta).with(subject)
        subject.handle
      end
    end

    context 'user has subscriptions' do
      it 'sends the has subscriptions cta' do
        subject.user.member_profile.add_community(create(:community))
        expect(Responder)
          .to receive(:send_has_subscription_cta).with(subject, 1)
        subject.handle
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
          .to eq ChatService.new(message).send(:cta_options)
      end
    end
  end
end
