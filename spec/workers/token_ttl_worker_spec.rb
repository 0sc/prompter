require 'rails_helper'
RSpec.describe TokenTtlWorker, type: :worker do
  let(:user_one) { create(:user, expires_at: Time.current.to_i) }
  let(:user_two) { create(:user, expires_at: 1.year.ago.to_i) }
  let(:user_three) { create(:user, expires_at: 1.year.from_now.to_i) }

  before do
    create(:community_admin_profile, admin_profile: user_one.admin_profile)
    create(:community_admin_profile, admin_profile: user_two.admin_profile)
    create(:community_admin_profile, admin_profile: user_three.admin_profile)
  end

  describe 'admin profiles with tokens expiring withing 2 days' do
    before { user_one.update!(expires_at: 110.minutes.from_now.to_i) }

    it 'sends send_access_token_expiring_notice if psid is present' do
      TokenTtlWorker.perform_async
      expect(TokenTtlWorker.jobs.size).to eq 1
      expect(TokenTtlWorker.jobs.first['args']).to be_empty

      expect(Notifier).to receive(:send_access_token_expiring_notice)
        .with(psid: user_one.psid, num_admin_comms: 1)

      TokenTtlWorker.drain
    end

    it 'does not send notice if psid is missing' do
      user_one.update(psid: nil)
      expect(Notifier).not_to receive(:send_access_token_expiring_notice)
      TokenTtlWorker.drain
    end

    it 'does not send notice if there are no assoc admin_communities' do
      user_one.admin_profile_communities.map(&:destroy!)
      expect(Notifier).not_to receive(:send_access_token_expiring_notice)
      TokenTtlWorker.drain
    end
  end

  describe 'admin profiles with tokens that expired within 1 hour' do
    before { user_one.update(expires_at: 40.minutes.ago.to_i) }

    it 'sends send_access_token_expired_notice if psid is present' do
      TokenTtlWorker.perform_async
      expect(TokenTtlWorker.jobs.size).to eq 1
      expect(TokenTtlWorker.jobs.first['args']).to be_empty

      expect(Notifier).to receive(:send_access_token_expired_notice)
        .with(psid: user_one.psid, num_admin_comms: 1)

      TokenTtlWorker.drain
    end

    it 'does not send notice if psid is missing' do
      user_one.update(psid: nil)
      expect(Notifier).not_to receive(:send_access_token_expired_notice)
      TokenTtlWorker.drain
    end

    it 'does not send notice if there are no assoc admin_communities' do
      user_one.admin_profile_communities.map(&:destroy!)
      expect(Notifier).not_to receive(:send_access_token_expired_notice)
      TokenTtlWorker.drain
    end
  end
end
