class AdminProfile < ApplicationRecord
  belongs_to :user

  has_many :community_admin_profiles, dependent: :destroy
  has_many :communities, through: :community_admin_profiles

  alias admin_communities communities

  def add_community(community)
    communities << community unless communities.include? community
  end

  def remove_community(community)
    community_admin_profiles.where(community: community).map(&:destroy)
  end

  def transfer_communities_to(profile)
    raise "Not found profile: #{profile}" unless profile.persisted?

    community_admin_profiles.update_all(admin_profile_id: profile.id)
  end
end
