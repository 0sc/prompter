class AdminProfile < ApplicationRecord
  belongs_to :user

  has_many :community_admin_profiles, dependent: :destroy
  has_many :communities, through: :community_admin_profiles

  alias admin_communities communities

  def add_community(community)
    communities << community unless communities.include? community
  end
end
