FactoryBot.define do
  factory :community do
    sequence(:fbid) { |n| "something-#{n}" }
    name 'my-awesome-fb-group'
  end
end
