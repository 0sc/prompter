FactoryBot.define do
  factory :community do
    community_type
    sequence(:fbid) { |n| "something-#{n}" }
    name 'my-awesome-fb-group'
    sequence(:referral_code) { |n| "something-#{n}" }
    icon 'https://my-group-icon.png'
    cover 'https://my-group-cover-image.jpg'
    qrcode 'https://my-group-messenger-qr-image.jpg'

    trait :with_feed_categories do
      transient do
        amount 0
      end

      after(:create) do |community, evaluator|
        create_list :community_type_feed_category,
                    evaluator.amount,
                    community_type: community.community_type
      end
    end
  end
end
