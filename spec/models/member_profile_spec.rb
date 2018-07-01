require 'rails_helper'

RSpec.describe MemberProfile, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:community_member_profiles) }
  it { should have_many(:communities).through(:community_member_profiles) }

  describe 'aliases' do
    it 'aliases #member_communities as communities' do
      expect(subject.member_communities).to eq subject.communities
    end
  end

  describe '#subscriptions?' do
    context 'communities present' do
      it 'returns true' do
        subject.communities << create(:community)
        expect(subject.subscriptions?).to be true
      end
    end

    context 'no communities present' do
      it 'returns false' do
        subject.community_member_profiles.map(&:destroy)
        expect(subject.subscriptions?).to be false
      end
    end
  end
end
