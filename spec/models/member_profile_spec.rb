require 'rails_helper'

RSpec.describe MemberProfile, type: :model do
  subject { create(:member_profile) }
  let(:community) { create(:community) }

  it { should belong_to(:user) }
  it { should have_many(:community_member_profiles) }
  it { should have_many(:communities).through(:community_member_profiles) }

  describe '#communities?' do
    context 'communities present' do
      it 'returns true' do
        subject.communities << community
        expect(subject.communities?).to be true
      end
    end

    context 'no communities present' do
      it 'returns false' do
        subject.community_member_profiles.map(&:destroy)
        expect(subject.communities?).to be false
      end
    end
  end

  describe '#community?' do
    it 'returns true if the member profile has the given community' do
      subject.communities << community
      expect(subject.community?(community)).to be true
    end

    it 'returns false if member profile does not have the given community' do
      subject.community_member_profiles.where(community: community).map(&:destroy)
      expect(subject.community?(community)).to be false
    end
  end

  describe '#community_count' do
    it 'returns number of communities a user is subscribed to' do
      create_list(:community, 2).each do |community|
        subject.add_community(community)
      end

      expect(subject.community_count).to be 2
    end
  end

  describe '#add_community' do
    context 'profile already has community' do
      before { subject.communities << community }

      it "doesn't double add the community" do
        expect { subject.add_community(community) }
          .not_to(change { subject.communities.count })
        expect(subject.communities).to include(community)
      end

      it 'returns the community member profile' do
        profile = subject.community_member_profiles.last
        expect(subject.add_community(community)).to eq profile
      end
    end

    context "profile doesn't have community" do
      it 'adds the community' do
        expect { subject.add_community(community) }
          .to(change { subject.communities.count }.from(0).to(1))

        expect(subject.communities).to include(community)
      end

      it 'returns the community member profile' do
        expect(subject.add_community(community))
          .to eq CommunityMemberProfile.last
      end
    end
  end

  describe '#remove_community' do
    before { subject.communities << community }

    it 'removes the community from the member_profile' do
      expect { subject.remove_community(community) }
        .to change { subject.communities.count }.from(1).to(0)
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
