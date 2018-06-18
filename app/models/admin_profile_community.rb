class AdminProfileCommunity < ApplicationRecord
  belongs_to :admin_profile
  belongs_to :community
end
