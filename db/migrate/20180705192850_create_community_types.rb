class CreateCommunityTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :community_types do |t|
      t.timestamps
      t.string :name, null: false
    end
  end
end
