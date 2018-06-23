require 'rails_helper'

RSpec.describe CommunityAdminProfile, type: :model do
  subject { create(:community_admin_profile) }
  
  it { should belong_to(:community) }
  it { should belong_to(:admin_profile) }

  it { should validate_uniqueness_of(:community_id).scoped_to(:admin_profile_id) }
end
