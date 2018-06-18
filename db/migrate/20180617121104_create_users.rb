class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.timestamps

      t.string :name, null: false
      t.string :email, null: false
      t.integer :fbid, null: false, limit: 8
      t.string :image
      t.string :token, null: false
      t.integer :expires_at, null: false
    end

    add_index :users, :fbid
  end
end
