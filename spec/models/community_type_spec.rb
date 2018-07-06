require 'rails_helper'

RSpec.describe CommunityType, type: :model do
  subject { create(:community_type) }

  it { should have_many(:communities).dependent(:nullify) }
  it { should have_many(:community_type_feed_categories).dependent(:destroy) }
  it do
    should have_many(:feed_categories).through(:community_type_feed_categories)
  end

  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
end
