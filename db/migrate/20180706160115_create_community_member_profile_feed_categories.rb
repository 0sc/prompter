class CreateCommunityMemberProfileFeedCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :community_member_profile_feed_categories do |t|
      cp_idx_name = 'idx_comm_member_profile_feed_cat_on_comm_member_profile_id'
      fc_index_name = 'idx_comm_member_profile_feed_cat_on_feed_category_id'

      t.references :community_member_profile,
                   foreign_key: true,
                   null: false,
                   index: { name: cp_idx_name }

      t.references :feed_category,
                   foreign_key: true,
                   null: false,
                   index: { name: fc_index_name }

      t.timestamps
    end
  end
end
