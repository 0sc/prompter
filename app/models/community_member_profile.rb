class CommunityMemberProfile < ApplicationRecord
  belongs_to :member_profile
  belongs_to :community
  has_many :community_member_profile_feed_categories, dependent: :destroy
  has_many :feed_categories, through: :community_member_profile_feed_categories

  validates_presence_of :community_id, :member_profile_id
  validates_uniqueness_of :community_id, scope: :member_profile_id

  after_create :subscribe_to_all_feed_categories
  # after_save :destroy, unless: :subscribed_feed_category?

  delegate :feed_category?, to: :community

  def subscribe_to_all_feed_categories
    self.feed_categories = community.feed_categories
    save
  end

  def subscribe_to_feed_category(feed_category)
    return true if community_member_profile_feed_categories.exists?(
      feed_category: feed_category
    )

    # TODO: consider changing this to user update or save
    # will raise error if validation fails
    feed_categories << feed_category
  end

  def unsubscribe_from_feed_category(feed_category)
    community_member_profile_feed_categories
      .where(feed_category: feed_category)
      .map(&:destroy)
  end

  def subscribed_feed_category?
    !feed_categories.empty?
  end
end
