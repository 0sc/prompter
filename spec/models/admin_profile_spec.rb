require 'rails_helper'

RSpec.describe AdminProfile, type: :model do
  subject { create(:admin_profile) }
  let(:community) { create(:community) }

  it { should belong_to(:user) }
  it { should have_many(:community_admin_profiles) }
  it { should have_many(:communities).through(:community_admin_profiles) }

  describe 'aliases' do
    it 'aliases #admin_communities as communities' do
      expect(subject.admin_communities).to eq subject.communities
    end
  end

  describe '#add_community' do

    context 'profile already has community' do
      it "doesn't double add the community" do
        subject.communities << community

        expect { subject.add_community(community) }
          .not_to(change { subject.communities.count })
        expect(subject.communities).to include(community)
      end
    end

    context "profile doesn't have community" do
      it 'adds the community' do
        expect { subject.add_community(community) }
          .to(change { subject.communities.count }.from(0).to(1))

        expect(subject.communities).to include(community)
      end
    end
  end

  describe '#remove_community' do
    before { subject.communities << community }

    it 'removes the community from the admin_profile' do
      expect { subject.remove_community(community) }
        .to change { subject.communities.count }.from(1).to(0)
    end
  end

  describe '#transfer_communities_to' do
    let(:profile_one) { create(:admin_profile) }
    let(:profile_two) { build(:admin_profile) }

    before(:each) do
      create_list(:community_admin_profile, 2, admin_profile: profile_one)
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
