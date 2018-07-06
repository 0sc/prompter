class CreateFeedCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :feed_categories do |t|
      t.timestamps
      t.string :name, null: false
    end
  end
end
