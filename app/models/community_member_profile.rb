class CommunityMemberProfile < ApplicationRecord
  belongs_to :member_profile
  belongs_to :community
  has_many :community_member_profile_feed_categories, dependent: :destroy
  has_many :feed_categories, through: :community_member_profile_feed_categories

  validates_presence_of :community_id, :member_profile_id
  validates_uniqueness_of :community_id, scope: :member_profile_id
end
