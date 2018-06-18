require 'rails_helper'

RSpec.describe MemberProfile, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:member_profile_communities) }
  it { should have_many(:communities).through(:member_profile_communities) }

  describe 'aliases' do
    it 'aliases #member_communities as communities' do
      expect(subject.member_communities).to eq subject.communities
    end
  end
end
