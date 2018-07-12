class FeedCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :community_type_feed_categories, dependent: :destroy
  has_many :community_types, through: :community_type_feed_categories
end
