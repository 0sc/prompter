class MemberProfile < ApplicationRecord
  belongs_to :user

  has_many :community_member_profiles, dependent: :destroy
  has_many :communities, through: :community_member_profiles

  alias member_communities communities

  def subscriptions?
    communities.present?
  end

  def add_community(community)
    communities << community unless communities.include? community
  end

  def remove_community(community)
    community_member_profiles.where(community: community).map(&:destroy)
  end

  def transfer_communities_to(profile)
    raise "Not found profile: #{profile}" unless profile.persisted?
    community_member_profiles.update_all(member_profile_id: profile.id)
  end
end
