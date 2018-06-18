require 'rails_helper'
require 'support/omniauth'

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

  describe 'delegates' do
    subject { create(:user) }

    it 'delegates #admin_communities to admin_profile' do
      expect(subject.admin_communities).to eq subject.admin_profile.admin_communities
    end

    it 'delegates #member_communities to admin_profile' do
      expect(subject.member_communities).to eq subject.member_profile.member_communities
    end
  end

  describe '#update_from_auth_hash' do
    it 'updates the user attributes with details from the auth hash' do
      target_attrs = %i[email name]
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
  end
end
