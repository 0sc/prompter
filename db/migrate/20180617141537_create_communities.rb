class CreateCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :communities do |t|
      t.timestamps

      t.string :fbid, null: false
      t.string :name, null: false
      t.string :referral_code, null: false
      t.string :cover
      t.string :icon
      t.string :qrcode
    end

    add_index :communities, :fbid
  end
end
