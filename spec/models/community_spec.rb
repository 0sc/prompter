require 'rails_helper'

RSpec.describe Community, type: :model do
  subject { build(:community) }

  it { should validate_presence_of(:fbid) }
  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:fbid) }
end
