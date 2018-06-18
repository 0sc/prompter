require 'rails_helper'

RSpec.describe MemberProfileCommunity, type: :model do
  it { should belong_to(:community) }
  it { should belong_to(:member_profile) }
end
