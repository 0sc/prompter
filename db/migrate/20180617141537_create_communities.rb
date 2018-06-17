class CreateCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :communities do |t|
      t.timestamps

      t.string :fbid, null: false
      t.string :name, null: false
    end

    add_index :communities, :fbid
  end
end
