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

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:fbid) }

  it { should have_one(:admin_profile) }
  it { should have_one(:member_profile) }

  it_should_behave_like 'messenger_profile'

  describe 'delegates' do
    subject { create(:user) }

    it 'delegates #admin_communities to admin_profile' do
      expect(subject.admin_communities)
        .to eq subject.admin_profile.admin_communities
    end

    it 'delegates #member_communities to admin_profile' do
      expect(subject.member_communities)
        .to eq subject.member_profile.member_communities
    end

    it 'delegates #subscriptions? to member_profile' do
      expect(subject.subscriptions?)
        .to eq subject.member_profile.subscriptions?
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
end
