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
end
