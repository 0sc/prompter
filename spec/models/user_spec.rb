require 'rails_helper'
require 'support/omniauth'
require 'models/concerns/messenger_profile'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:fbid) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:token) }
  it { should validate_presence_of(:expires_at) }

  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_uniqueness_of(:fbid).case_insensitive }

  it { should have_one(:admin_profile) }
  it { should have_one(:member_profile) }

  it_should_behave_like 'messenger_profile'

  describe 'delegates' do
    subject { create(:user) }

    it 'delegates #admin_profile_communities to admin_profile' do
      expect(subject.admin_profile_communities)
        .to eq subject.admin_profile.communities
    end

    it 'delegates #admin_profile_community_count to admin_profile' do
      expect(subject.admin_profile_community_count)
        .to eq subject.admin_profile.community_count
    end

    it 'delegates #member_profile_communities to member_profile' do
      expect(subject.member_profile_communities)
        .to eq subject.member_profile.communities
    end

    it 'delegates #member_profile_communities? to member_profile' do
      expect(subject.member_profile_communities?)
        .to eq subject.member_profile.communities?
    end

    it 'delegates #member_profile_community_count to member_profile' do
      expect(subject.member_profile_community_count)
        .to eq subject.member_profile.community_count
    end
  end

  describe '#update_from_auth_hash' do
    it 'updates the user attributes with details from the auth hash' do
      target_attrs = %i[email name image fbid]
      target_attrs.each { |attr| subject[attr] = 'something-random' }
      subject.token = '122333353fsdfafd'
      subject.expires_at = 1_234_567

      subject.update_from_auth_hash(SAMPLE_AUTH_HASH)

      target_attrs.each do |attr|
        expect(subject[attr]).to eq SAMPLE_AUTH_HASH[:info][attr]
      end

      %i[token expires_at].each do |attr|
        expect(subject[attr]).to eq SAMPLE_AUTH_HASH[:credentials][attr]
      end
    end

    context 'expire_at is missing' do
      it 'sets the expire_at to 20 days from now' do
        auth_hash = SAMPLE_AUTH_HASH.deep_dup
        auth_hash[:credentials].delete(:expires_at)
        subject.expires_at = 0
        expect(subject.expires_at).to be 0
        subject.update_from_auth_hash(auth_hash)
        expect(subject.expires_at).not_to be nil
        expect(subject.expires_at)
          .not_to eq auth_hash.dig(:credentials, :expires_at)
      end
    end

    context 'expire_at is present' do
      it 'sets the expires_at' do
        subject.expires_at = 0
        expect(subject.expires_at).to be 0
        subject.update_from_auth_hash(SAMPLE_AUTH_HASH)
        expect(subject.expires_at).not_to be 0
        expect(subject.expires_at)
          .to eq SAMPLE_AUTH_HASH.dig(:credentials, :expires_at)
      end
    end
  end

  describe '#account_linked?' do
    context 'fbid equals psid' do
      it 'returns false' do
        subject.psid = subject.fbid = 100_000
        expect(subject.account_linked?).to be false
      end
    end

    context 'has placeholder_email' do
      it 'returns false' do
        subject.email = subject.send(:build_placeholder_email, 'xyz')
        expect(subject.account_linked?).to be false
      end
    end

    context 'has placeholder_token' do
      it 'return false' do
        subject.token = MessengerProfile::TOKEN_PLACEHOLDER
        expect(subject.account_linked?).to be false
      end
    end

    it 'returns true if email, token, fbid, psid are valid' do
      subject.email = 'not-temp@valid.com'
      subject.token = 'not-placeholder-token'
      subject.fbid = 12345
      subject.psid = 67890

      expect(subject.account_linked?).to be true
    end
  end

  describe '.combine_accounts!' do
    let!(:acc_one) { create(:user) }
    let!(:acc_two) { create(:user) }

    it 'returns if an error occurred' do
      allow(acc_two.admin_profile)
        .to receive(:transfer_communities_to).and_raise('Boom!')
      expect { User.combine_accounts!(acc_one, acc_two) }.to raise_error 'Boom!'
      expect(acc_one.persisted?).to be true
      expect(acc_two.persisted?).to be true
    end

    it 'copies over missing attributes' do
      acc_one.update!(psid: nil)
      expect { User.combine_accounts!(acc_one, acc_two) }
        .to change { acc_one.reload.psid }.from(nil).to(acc_two.psid)
    end

    it 'transfers account two communites to account one' do
      admin_community_two = create(
        :community_admin_profile,
        admin_profile: acc_two.admin_profile
      ).community

      member_community_two = create(
        :community_member_profile,
        member_profile: acc_two.member_profile
      ).community

      admin_community_one = create(
        :community_admin_profile,
        admin_profile: acc_one.admin_profile
      ).community

      member_community_one = create(
        :community_member_profile,
        member_profile: acc_one.member_profile
      ).community

      expect(acc_one.admin_profile_communities)
        .to match_array([admin_community_one])
      expect(acc_one.member_profile_communities)
        .to match_array([member_community_one])

      expect(acc_two.admin_profile_communities)
        .to match_array([admin_community_two])
      expect(acc_two.member_profile_communities)
        .to match_array([member_community_two])

      User.combine_accounts!(acc_one, acc_two)
      acc_one.reload

      expect(acc_one.admin_profile_communities)
        .to match_array([admin_community_one, admin_community_two])
      expect(acc_one.member_profile_communities)
        .to match_array([member_community_one, member_community_two])
    end

    it 'destroys the second account' do
      expect { User.combine_accounts!(acc_one, acc_two) }
        .to change { User.count }.from(2).to(1)
      expect(User.all).to eq [acc_one]
    end
  end

  describe '#token_expired?' do
    it 'returns true if user token has expired' do
      subject.expires_at = 2.minutes.ago.to_i
      expect(subject.token_expired?).to be true
    end

    it 'returns false if user token is not expired' do
      subject.expires_at = 10.minutes.from_now.to_i
      expect(subject.token_expired?).to be false
    end
  end

  describe '#psid?' do
    it 'returns true if user has psid' do
      subject.psid = '1121321'
      expect(subject.psid?).to be true
    end

    it 'returns false if user has no psid' do
      subject.psid = nil
      expect(subject.psid?).to be false
    end
  end
end
