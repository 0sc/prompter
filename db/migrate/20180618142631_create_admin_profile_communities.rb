class CreateAdminProfileCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_profile_communities do |t|
      t.timestamps
      t.references :admin_profile, foreign_key: true
      t.references :community, foreign_key: true
    end
  end
end
