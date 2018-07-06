class CommunityMemberProfileFeedCategory < ApplicationRecord
  belongs_to :community_member_profile
  belongs_to :feed_category

  validates_presence_of :community_member_profile_id, :feed_category_id
  validates_uniqueness_of :community_member_profile_id, scope: :feed_category_id
end
