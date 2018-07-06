# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_07_06_160115) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "communities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fbid", null: false
    t.string "name", null: false
    t.string "cover"
    t.string "icon"
    t.bigint "community_type_id"
    t.index ["community_type_id"], name: "index_communities_on_community_type_id"
    t.index ["fbid"], name: "index_communities_on_fbid"
  end

  create_table "community_admin_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_profile_id", null: false
    t.bigint "community_id", null: false
    t.index ["admin_profile_id"], name: "index_community_admin_profiles_on_admin_profile_id"
    t.index ["community_id"], name: "index_community_admin_profiles_on_community_id"
  end

  create_table "community_member_profile_feed_categories", force: :cascade do |t|
    t.bigint "community_member_profile_id", null: false
    t.bigint "feed_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_member_profile_id"], name: "idx_comm_member_profile_feed_cat_on_comm_member_profile_id"
    t.index ["feed_category_id"], name: "idx_comm_member_profile_feed_cat_on_feed_category_id"
  end

  create_table "community_member_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_profile_id", null: false
    t.bigint "community_id", null: false
    t.index ["community_id"], name: "index_community_member_profiles_on_community_id"
    t.index ["member_profile_id"], name: "index_community_member_profiles_on_member_profile_id"
  end

  create_table "community_type_feed_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "community_type_id", null: false
    t.bigint "feed_category_id", null: false
    t.index ["community_type_id"], name: "index_community_type_feed_categories_on_community_type_id"
    t.index ["feed_category_id"], name: "index_community_type_feed_categories_on_feed_category_id"
  end

  create_table "community_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
  end

  create_table "feed_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
  end

  create_table "member_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_member_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.bigint "fbid", null: false
    t.bigint "psid"
    t.string "image"
    t.string "token", null: false
    t.integer "expires_at", null: false
    t.index ["fbid"], name: "index_users_on_fbid"
  end

  add_foreign_key "admin_profiles", "users"
  add_foreign_key "communities", "community_types"
  add_foreign_key "community_admin_profiles", "admin_profiles"
  add_foreign_key "community_admin_profiles", "communities"
  add_foreign_key "community_member_profile_feed_categories", "community_member_profiles"
  add_foreign_key "community_member_profile_feed_categories", "feed_categories"
  add_foreign_key "community_member_profiles", "communities"
  add_foreign_key "community_member_profiles", "member_profiles"
  add_foreign_key "community_type_feed_categories", "community_types"
  add_foreign_key "community_type_feed_categories", "feed_categories"
  add_foreign_key "member_profiles", "users"
end
