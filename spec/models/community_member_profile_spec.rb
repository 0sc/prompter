require 'rails_helper'

RSpec.describe CommunityMemberProfile, type: :model do
  subject { create(:community_member_profile) }
  
  it { should belong_to(:community) }
  it { should belong_to(:member_profile) }

  it { should validate_uniqueness_of(:community_id).scoped_to(:member_profile_id) }
end
