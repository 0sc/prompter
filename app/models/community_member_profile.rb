class CommunityMemberProfile < ApplicationRecord
  belongs_to :member_profile
  belongs_to :community

  validates_presence_of :community_id, :member_profile_id
  validates_uniqueness_of :community_id, scope: :member_profile_id
end
