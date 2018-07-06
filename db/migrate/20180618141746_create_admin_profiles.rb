class CreateAdminProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_profiles do |t|
      t.timestamps
      t.references :user, foreign_key: true, null: false
    end
  end
end
