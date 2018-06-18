require 'rails_helper'

RSpec.describe AdminProfile, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:admin_profile_communities) }
  it { should have_many(:communities).through(:admin_profile_communities) }

  describe 'aliases' do
    it 'aliases #admin_communities as communities' do
      expect(subject.admin_communities).to eq subject.communities
    end
  end
end
