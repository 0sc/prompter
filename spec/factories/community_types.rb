FactoryBot.define do
  factory :community_type do
    sequence(:name) { |n| "community-type-#{n}" }
  end
end
