FactoryBot.define do
  factory :community do
    sequence(:fbid) { |n| "something-#{n}" }
    name 'my-awesome-fb-group'
    icon 'my-group-icon.png'
    cover 'my-group-cover-image.jpg'
  end
end
