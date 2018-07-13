require 'rails_helper'
require 'support/omniauth'

RSpec.describe Chat::ReferralService, type: :service do
  let(:message) { double }
  subject { Chat::ReferralService.new(message) }
  let(:user) { subject.user }
  let(:community) { create(:community) }
  let(:ref_code) { community.referral_code }

  before do
    allow_any_instance_of(User).to receive(:profile_details_from_messenger)
      .and_return(SAMPLE_MESSENGER_PROFILE)
    allow(message).to receive(:sender).and_return('id' => 100)
  end

  describe '#handle' do
    describe 'valid referral_code' do
      before do
        allow(message).to receive(:messaging).and_return referral_payload

        expect(Responder).to receive(:send_subscribed_to_community_cta)
          .with(subject, instance_of(CommunityMemberProfile))
      end

      it 'sends the subscribed to community cta' do
        subject.handle
      end

      it 'subscribes the user to the community' do
        expect(user.reload.member_profile_communities).to eq []
        subject.handle
        expect(user.reload.member_profile_communities).to eq [community]
      end
    end

    describe 'invalid referral code' do
      before do
        allow(message).to receive(:messaging).and_return referral_payload(404)
      end

      context 'user has communities to manage' do
        before do
          user.member_profile.add_community(community)
          expect(Responder)
            .to receive(:send_get_started_cta).with(subject, true)
        end

        it 'sends the get_started_cta with manage options' do
          subject.handle
        end

        it 'does not subscribes the user to any community' do
          expect(user.reload.member_profile_communities).to eq [community]
          subject.handle
          expect(user.reload.member_profile_communities).to eq [community]
        end
      end

      context 'user does not have communities to manage' do
        before do
          user.member_profile_communities.map(&:destroy)
          expect(Responder)
            .to receive(:send_get_started_cta).with(subject, false)
        end

        it 'sends the get_started_cta without manage options' do
          subject.handle
        end

        it 'does not subscribes the user to any community' do
          expect(user.reload.member_profile_communities).to eq []
          subject.handle
          expect(user.reload.member_profile_communities).to eq []
        end
      end
    end
  end

  def referral_payload(code = ref_code)
    {
      'referral' => {
        'ref' => code,
        'source' => 'SHORTLINK',
        'type' => 'OPEN_THREAD'
      }
    }
  end
end
