require 'rails_helper'

RSpec.describe CommunityMemberProfileFeedCategory, type: :model do
  subject { create(:community_member_profile_feed_category) }

  it { should belong_to(:community_member_profile) }
  it { should belong_to(:feed_category) }

  it { should validate_presence_of(:community_member_profile_id) }
  it { should validate_presence_of(:feed_category_id) }
  it do
    should validate_uniqueness_of(:community_member_profile_id)
      .scoped_to(:feed_category_id)
  end
end
