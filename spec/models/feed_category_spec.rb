require 'rails_helper'

RSpec.describe FeedCategory, type: :model do
  subject { build(:feed_category) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }

  it { should have_many(:community_type_feed_categories).dependent(:destroy) }
  it do
    should have_many(:community_types).through(:community_type_feed_categories)
  end
end
