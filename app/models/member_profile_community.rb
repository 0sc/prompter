class MemberProfileCommunity < ApplicationRecord
  belongs_to :member_profile
  belongs_to :community
end
