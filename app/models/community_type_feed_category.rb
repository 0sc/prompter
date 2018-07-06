class CommunityTypeFeedCategory < ApplicationRecord
  validates_uniqueness_of :community_type_id, scope: :feed_category_id

  belongs_to :community_type
  belongs_to :feed_category
end
