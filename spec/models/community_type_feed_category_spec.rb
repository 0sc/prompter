require 'rails_helper'

RSpec.describe CommunityTypeFeedCategory, type: :model do
  subject { create(:community_type_feed_category) }

  it { should belong_to(:community_type) }
  it { should belong_to(:feed_category) }

  it do
    should validate_uniqueness_of(:community_type_id)
      .scoped_to(:feed_category_id)
  end
end
