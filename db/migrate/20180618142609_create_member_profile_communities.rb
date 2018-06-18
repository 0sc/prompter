class CreateMemberProfileCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :member_profile_communities do |t|
      t.timestamps
      t.references :member_profile, foreign_key: true
      t.references :community, foreign_key: true
    end
  end
end
