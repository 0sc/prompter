class CommunityMemberProfile < ApplicationRecord
  belongs_to :member_profile
  belongs_to :community

  validates_uniqueness_of :community_id, scope: :member_profile_id
end
