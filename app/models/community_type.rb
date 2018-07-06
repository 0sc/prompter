class CommunityType < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :communities, dependent: :nullify
  has_many :community_type_feed_categories, dependent: :destroy
  has_many :feed_categories, through: :community_type_feed_categories

  def add_feed_category(fd_category)
    feed_categories << fd_category unless feed_categories.include? fd_category
  end

  def remove_feed_category(feed_category)
    community_type_feed_categories.where(feed_category: feed_category)
                                  .map(&:destroy)
  end

  def feed_category?(feed_category)
    community_type_feed_categories.exists?(feed_category: feed_category)
  end
end
