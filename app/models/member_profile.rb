class MemberProfile < ApplicationRecord
  belongs_to :user

  has_many :community_member_profiles, dependent: :destroy
  has_many :communities, through: :community_member_profiles

  alias member_communities communities

  def subscriptions?
    communities.present?
  end
end
