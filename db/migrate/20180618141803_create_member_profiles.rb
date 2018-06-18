class CreateMemberProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :member_profiles do |t|
      t.timestamps
      t.references :user, foreign_key: true
    end
  end
end
