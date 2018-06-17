require 'rails_helper'
require 'support/omniauth'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:token) }
  it { should validate_presence_of(:expires_at) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:uid) }

  describe '#update_from_auth_hash' do
    it 'updates the user attributes with details from the auth hash' do
      target_attrs = %i[email first_name last_name]
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

  describe '#name' do
    it 'returns name as a combination of first_name and last_name' do
      name = subject.first_name + ' ' + subject.last_name
      expect(subject.name).to eq name
    end
  end
end
