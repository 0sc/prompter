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

  describe '#transfer_communities_to' do
    let(:profile_one) { create(:member_profile) }
    let(:profile_two) { build(:member_profile) }

    before(:each) do
      create_list(:community_member_profile, 2, member_profile: profile_one)
    end

    after(:each) { expect(Community.count).to eq 2 }

    context 'target_profile exists' do
      before(:each) { profile_two.save }

      it 'returns a truthy value' do
        expect(profile_one.transfer_communities_to(profile_two)).to be_truthy
      end
      it 'transfers all communities to target profile' do
        expect(profile_two.communities).to eq []
        expect(profile_one.communities).to eq Community.all

        expect(profile_one.transfer_communities_to(profile_two)).to be_truthy

        expect(profile_two.reload.communities).to eq Community.all
        expect(profile_one.reload.communities).to eq []
      end
    end

    context 'target_profile does not exist' do
      it 'raise an error and does not transfer communities' do
        expect(profile_two.communities).to eq []
        expect(profile_one.communities).to eq Community.all

        expect { profile_one.transfer_communities_to(profile_two) }
          .to raise_error("Not found profile: #{profile_two}")

        expect(profile_one.reload.communities).to eq Community.all
        expect(profile_two.communities).to eq []
      end
    end
  end
end
