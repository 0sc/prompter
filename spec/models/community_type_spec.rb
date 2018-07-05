require 'rails_helper'

RSpec.describe CommunityType, type: :model do
  subject { create(:community_type) }

  it { should have_many(:communities).dependent(:nullify) }

  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
end
