FactoryBot.define do
  factory :community do
    community_type
    sequence(:fbid) { |n| "something-#{n}" }
    name 'my-awesome-fb-group'
    icon 'https://my-group-icon.png'
    cover 'https://my-group-cover-image.jpg'
  end
end
