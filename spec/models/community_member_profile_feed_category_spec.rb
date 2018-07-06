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

  describe 'validating that community type belongs to the feed_category' do
    let!(:feed_category) { create(:feed_category) }
    let!(:community) { create(:community) }
    let!(:comm_member_profile) do
      create(:community_member_profile, community: community)
    end

    subject do
      build(:community_member_profile_feed_category,
            feed_category: nil,
            community_member_profile: comm_member_profile)
    end

    it 'flags an error if feed_category is not associated with comm type' do
      subject.feed_category = feed_category
      name = feed_category.name
      expect(subject.valid?).to be false
      expect(subject.errors.messages).to include(
        feed_category: ["feed category: #{name} is invalid for community type"]
      )
    end

    it 'does not flag an error if feed_category is associated with comm type' do
      community.community_type.add_feed_category(feed_category)
      subject.feed_category_id = feed_category.id

      expect(subject.valid?).to be true
      expect(subject.errors).to be_empty
    end
  end
end
