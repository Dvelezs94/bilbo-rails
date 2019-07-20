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

ActiveRecord::Schema.define(version: 2019_07_18_231031) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "ads", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.string "decline_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ads_artworks", id: false, force: :cascade do |t|
    t.bigint "ad_id", null: false
    t.bigint "artwork_id", null: false
    t.index ["ad_id", "artwork_id"], name: "index_ads_artworks_on_ad_id_and_artwork_id"
    t.index ["artwork_id", "ad_id"], name: "index_ads_artworks_on_artwork_id_and_ad_id"
  end

  create_table "artworks", force: :cascade do |t|
    t.integer "width"
    t.integer "height"
    t.string "image"
    t.bigint "ads_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ads_id"], name: "index_artworks_on_ads_id"
  end

  create_table "bilbos", force: :cascade do |t|
    t.bigint "user_id"
    t.float "latitude"
    t.float "longitude"
    t.integer "avg_daily_views"
    t.float "width"
    t.float "height"
    t.integer "duration"
    t.integer "status"
    t.integer "face"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bilbos_on_user_id"
  end

  create_table "bilbos_campaigns", id: false, force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "bilbo_id", null: false
    t.index ["bilbo_id", "campaign_id"], name: "index_bilbos_campaigns_on_bilbo_id_and_campaign_id"
    t.index ["campaign_id", "bilbo_id"], name: "index_bilbos_campaigns_on_campaign_id_and_bilbo_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "description"
    t.float "budget"
    t.integer "status"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ad_id"
    t.index ["ad_id"], name: "index_campaigns_on_ad_id"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "status"
    t.bigint "campaign_id"
    t.integer "prints"
    t.float "total"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_orders_on_campaign_id"
  end

  create_table "prints", force: :cascade do |t|
    t.bigint "bilbo_id"
    t.float "price", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bilbo_id"], name: "index_prints_on_bilbo_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "timezone"
    t.string "name"
    t.string "company_name"
    t.string "provider"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "artworks", "ads", column: "ads_id"
  add_foreign_key "bilbos", "users"
  add_foreign_key "campaigns", "ads"
  add_foreign_key "campaigns", "users"
  add_foreign_key "orders", "campaigns"
  add_foreign_key "prints", "bilbos"
end
