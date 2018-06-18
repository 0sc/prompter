class MemberProfile < ApplicationRecord
  belongs_to :user

  has_many :member_profile_communities, dependent: :destroy
  has_many :communities, through: :member_profile_communities

  alias member_communities communities
end
