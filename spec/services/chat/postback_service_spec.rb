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
    allow(message).to receive(:sender).and_return('id' => 100)
  end

  describe '#handle' do
    context 'subscribe_to_community' do
      describe 'community not found' do
        before do
          allow(message).to receive(:messaging).and_return subscribe_to_com(404)
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
          allow(message).to receive(:messaging).and_return subscribe_to_com(id)

          expect(Responder).to receive(:send_subscribed_to_community_cta)
            .with(subject, instance_of(CommunityMemberProfile))
        end

        it 'sends the subscribed_to_community_cta' do
          subject.handle
        end

        it 'subscribes user to the community' do
          expect(user.reload.member_profile_communities).to eq []
          subject.handle
          expect(user.reload.member_profile_communities).to eq [community]
        end
      end
    end

    context 'get_started' do
      before(:each) do
        expect(Responder).to receive(:send_welcome_note).with(subject)
      end

      shared_examples 'standard get started' do
        it 'sets the get started to without manage option' do
          expect(Responder)
            .to receive(:send_get_started_cta).with(subject, false)
          subject.handle
        end
      end

      describe 'from referral' do
        context 'valid referral code' do
          before do
            allow(message).to receive(:messaging)
              .and_return get_started(community.referral_code)
            expect(Responder)
              .to receive(:send_get_started_cta).with(subject, true)
          end

          it 'subscribes the user to the community' do
            expect(user.reload.member_profile_communities).to eq []
            subject.handle
            expect(user.reload.member_profile_communities).to eq [community]
          end
        end

        context 'invalid referral code' do
          before do
            allow(message).to receive(:messaging)
              .and_return get_started(404)
          end

          it_behaves_like 'standard get started'
        end
      end

      describe 'not from referral' do
        before { allow(message).to receive(:messaging).and_return get_started }
        it_behaves_like 'standard get started'
      end
    end
  end

  def subscribe_to_com(id = valid_community_id)
    payload = {
      'payload' => "#{Chat::PostbackService::SUBSCRIBE_TO_COMMUNITY}_#{id}"
    }
    postback_payload(payload)
  end

  def get_started(ref_code = nil)
    payload = { 'payload' => Chat::PostbackService::GET_STARTED }
    payload['referral'] = referral_payload(ref_code) if ref_code.present?
    postback_payload(payload)
  end

  def referral_payload(code)
    {
      'ref' => code,
      'source' => 'SHORTLINK',
      'type' => 'OPEN_THREAD'
    }
  end

  def postback_payload(payload)
    { 'postback' => payload }
  end
end
