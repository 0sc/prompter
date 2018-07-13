require 'rails_helper'

RSpec.describe Chat::AccountLinkService, type: :service do
  let(:message) { double }
  subject { Chat::AccountLinkService.new(message) }

  before do
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
    allow(message).to receive(:sender).and_return('id' => 100)
  end

  describe '#handle' do
    it 'calls the send account linked cta' do
      expect(Responder).to receive(:send_account_linked_cta).with(subject)
      subject.handle
    end
  end
end
