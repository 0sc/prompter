require 'rails_helper'
require 'support/omniauth'

RSpec.describe Chat::PostbackService, type: :service do
  let(:message) { double }
  subject { Chat::PostbackService.new(message) }
  let(:user) { subject.user }
  let(:community) { create(:community) }
  let(:valid_community_id) { community.id }

  before do
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
  end

  before(:each) do
    allow(message).to receive(:sender).and_return('id' => 100)
    allow(message).to receive(:messaging).and_return(postback_payload)
  end

  describe '#handle' do
    context 'subscribe_to_community' do
      describe 'community not found' do
        before(:each) do
          allow(message).to receive(:messaging).and_return postback_payload(404)
        end

        it 'sends the community_not_found_cta' do
          expect(Responder)
            .to receive(:send_community_not_found_cta).with(subject)
          subject.handle
        end
      end

      describe 'community found' do
        before(:each) do
          id = valid_community_id
          allow(message).to receive(:messaging).and_return postback_payload(id)

          expect(Responder).to receive(:send_subscribed_to_community_cta)
            .with(subject, instance_of(CommunityMemberProfile))
        end

        it 'sends the subscribed_to_community_cta' do
          subject.handle
        end

        it 'subscribes user to the community' do
          expect(user.reload.member_communities).to eq []
          subject.handle
          expect(user.reload.member_communities).to eq [community]
        end
      end
    end
  end

  def postback_payload(id = valid_community_id)
    {
      'postback' => {
        'payload' => "#{Chat::PostbackService::SUBSCRIBE_TO_COMMUNITY}_#{id}"
      }
    }
  end
end
