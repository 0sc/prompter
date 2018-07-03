class Community < ApplicationRecord
  validates :name, presence: true
  validates :fbid, presence: true, uniqueness: true

  has_many :community_admin_profiles
  has_many :community_member_profiles
  has_many :admin_profiles, through: :community_admin_profiles
  has_many :member_profiles, through: :community_member_profiles

  def update_from_fb_graph!(graph_info)
    self.name = graph_info['name']
    self.cover = graph_info.dig('cover', 'source')
    self.icon = graph_info['icon']
    save!
  end
end
