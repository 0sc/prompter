class CommunityAdminProfile < ApplicationRecord
  belongs_to :admin_profile
  belongs_to :community

  validates_presence_of :community_id, :admin_profile_id
  validates_uniqueness_of :community_id, scope: :admin_profile_id
end
