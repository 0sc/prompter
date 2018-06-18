class AdminProfile < ApplicationRecord
  belongs_to :user

  has_many :admin_profile_communities, dependent: :destroy
  has_many :communities, through: :admin_profile_communities

  alias admin_communities communities
end
