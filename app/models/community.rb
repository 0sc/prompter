class Community < ApplicationRecord
  validates :name, presence: true
  validates :fbid, presence: true, uniqueness: true

  has_many :community_admin_profiles
  has_many :community_member_profiles
  has_many :admin_profiles, through: :community_admin_profiles
  has_many :member_profiles, through: :community_member_profiles
end
