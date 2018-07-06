FactoryBot.define do
  factory :community_member_profile_feed_category do
    community_member_profile
    feed_category

    after(:build) do |object|
      # add feed_category to community_type to pass validation
      if object.feed_category.present?
        object.community_member_profile
              .community
              .community_type
              .add_feed_category(object.feed_category)
      end
    end
  end
end
