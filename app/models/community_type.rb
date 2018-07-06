class CommunityType < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :communities, dependent: :nullify
  has_many :community_type_feed_categories, dependent: :destroy
  has_many :feed_categories, through: :community_type_feed_categories
end
