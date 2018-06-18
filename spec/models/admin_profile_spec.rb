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
end
