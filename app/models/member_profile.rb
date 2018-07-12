class MemberProfile < ApplicationRecord
  belongs_to :user

  has_many :community_member_profiles, dependent: :destroy
  has_many :communities, through: :community_member_profiles

  def communities?
    communities.present?
  end

  def community?(community)
    community_member_profiles.exists?(community: community)
  end

  def community_count
    communities.count
  end

  def add_community(community)
    community_member_profiles.find_or_create_by(community: community)
  end

  def remove_community(community)
    community_member_profiles.where(community: community).map(&:destroy)
  end

  def transfer_communities_to(profile)
    raise "Not found profile: #{profile}" unless profile.persisted?
    community_member_profiles.update_all(member_profile_id: profile.id)
  end
end
