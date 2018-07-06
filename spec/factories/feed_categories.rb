FactoryBot.define do
  factory :feed_category do
    sequence(:name) { |n| "Feed Category #{n}" }
  end
end
