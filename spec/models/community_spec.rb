require 'rails_helper'

RSpec.describe Community, type: :model do
  subject { build(:community) }

  it { should validate_presence_of(:fbid) }
  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:fbid) }

  it { should have_many(:community_admin_profiles) }
  it { should have_many(:community_member_profiles) }
  it { should have_many(:admin_profiles).through(:community_admin_profiles) }
  it { should have_many(:member_profiles).through(:community_member_profiles) }
end
