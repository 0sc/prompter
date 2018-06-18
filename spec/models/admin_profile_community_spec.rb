require 'rails_helper'

RSpec.describe AdminProfileCommunity, type: :model do
  it { should belong_to(:community) }
  it { should belong_to(:admin_profile) }
end
