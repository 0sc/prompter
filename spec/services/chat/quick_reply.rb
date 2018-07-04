require 'support/omniauth'

shared_examples 'quick_reply' do
  subject { described_class.new(message) }
  let(:message) { double }
  let(:user) { subject.user }

  before do
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
  end

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => 100)
    allow(message).to receive(:messaging).and_return(quick_reply_payload)
  end

  describe '#handle_quick_reply' do
    before(:each) do
      attrs = attributes_for(:user).except(:id, :psid)
      subject.user.update!(attrs)
    end

    describe 'find-community payload' do
      before(:each) do
        allow(message).to receive(:messaging).and_return(find_community_payload)
      end

      context 'user account is not linked' do
        before(:each) { user.update(fbid: user.psid) } # fail acc linking test

        it 'responds with the link account cta' do
          expect(Responder).to receive(:send_link_account_cta).with(subject)
          subject.handle_quick_reply
        end
      end

      context 'user account access_token is expired' do
        before(:each) { user.update(expires_at: 2.days.ago) }

        it 'responds with renew token cta' do
          expect(Responder).to receive(:send_renew_token_cta).with(subject)
          subject.handle_quick_reply
        end
      end
    end

    describe 'subscribe-community payload' do
      before(:each) do
        allow(message).
          to receive(:messaging).and_return(subscribe_community_payload)
      end

      context 'user account is not linked' do
        before(:each) { user.update(fbid: user.psid) } # fail acc linking test

        it 'responds with the link account cta' do
          expect(Responder).to receive(:send_link_account_cta).with(subject)
          subject.handle_quick_reply
        end
      end

      context 'user account access_token is expired' do
        before(:each) { user.update(expires_at: 2.days.ago) }

        it 'responds with renew token cta' do
          expect(Responder).to receive(:send_renew_token_cta).with(subject)
          subject.handle_quick_reply
        end
      end
    end

    describe 'everything else' do
      it 'defaults to handle msg reply' do
        expect(subject).to receive(:handle_msg_reply)
        subject.handle_quick_reply
      end
    end
  end

  def find_community_payload
    quick_reply_payload.tap do |payload|
      payload['message']['quick_reply']['payload'] =
        Chat::QuickReply::FIND_COMMUNITIES
    end
  end

  def subscribe_communities_payload
    quick_reply_payload.tap do |payload|
      payload['message']['quick_reply']['payload'] =
        Chat::QuickReply::SUBSCRIBE_COMMUNITIES
    end
  end

  def quick_reply_payload(opts = {})
    {
      'message' => {
        'quick_reply' => { 'payload' => {} }
      }
    }.merge(opts)
  end
end
