require 'rails_helper'

RSpec.describe AdminProfile, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:community_admin_profiles) }
  it { should have_many(:communities).through(:community_admin_profiles) }

  describe 'aliases' do
    it 'aliases #admin_communities as communities' do
      expect(subject.admin_communities).to eq subject.communities
    end
  end

  describe '#add_community' do
    subject { create(:admin_profile) }
    let(:community) { create(:community) }

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
end
