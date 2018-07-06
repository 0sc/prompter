class CommunityMemberProfileFeedCategory < ApplicationRecord
  belongs_to :community_member_profile
  belongs_to :feed_category

  validates_presence_of :community_member_profile_id, :feed_category_id
  validates_uniqueness_of :community_member_profile_id, scope: :feed_category_id

  validate :community_type_feed_category

  def community_type_feed_category
    return unless community_member_profile.present?

    unless community_member_profile.feed_category?(feed_category)
      name = feed_category&.name
      msg = "feed category: #{name} is invalid for community type"
      errors.add(:feed_category, msg)
    end
  end
end
