class CreateCommunityAdminProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :community_admin_profiles do |t|
      t.timestamps
      t.references :admin_profile, foreign_key: true
      t.references :community, foreign_key: true
    end
  end
end
