class CommunityType < ApplicationRecord
  has_many :communities, dependent: :nullify
  validates :name, presence: true, uniqueness: true
end
