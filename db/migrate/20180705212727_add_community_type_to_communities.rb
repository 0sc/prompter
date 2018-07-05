class AddCommunityTypeToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_reference :communities, :community_type, foreign_key: true
  end
end
