class CreateCommunityTypeFeedCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :community_type_feed_categories do |t|
      t.timestamps
      t.references :community_type, foreign_key: true, null: false
      t.references :feed_category, foreign_key: true, null: false
    end
  end
end
