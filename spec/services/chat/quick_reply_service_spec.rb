require 'rails_helper'
require 'support/omniauth'

RSpec.describe Chat::QuickReplyService, type: :service do
  let(:message) { double }
  subject { Chat::QuickReplyService.new(message) }
  let(:user) { subject.user }

  before do
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
  end

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => 100)
    allow(message).to receive(:messaging).and_return(quick_reply_payload)
  end

  describe '#handle' do
    context 'not condition matches the payload' do
      let(:dummy) { double(ChatService) }
      before(:each) do
        stub_const('ChatService', double)
      end

      xit 'delegates processing to parent class' do
        # expect(subject).to receive(:handle).with('man')
        subject.handle
      end
    end
  end

  def quick_reply_payload(opts = {})
    { 'message' => { 'quick_reply' => { 'payload' => {} } } }.merge(opts)
  end
end
