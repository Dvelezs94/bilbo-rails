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

ActiveRecord::Schema.define(version: 2020_03_11_213908) do

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
    t.string "description"
    t.bigint "project_id"
    t.string "multimedia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "status", default: 0
    t.index ["project_id"], name: "index_ads_on_project_id"
    t.index ["slug"], name: "index_ads_on_slug", unique: true
  end

  create_table "ads_campaigns", id: false, force: :cascade do |t|
    t.bigint "ad_id", null: false
    t.bigint "campaign_id", null: false
    t.index ["ad_id", "campaign_id"], name: "index_ads_campaigns_on_ad_id_and_campaign_id"
    t.index ["campaign_id", "ad_id"], name: "index_ads_campaigns_on_campaign_id_and_ad_id"
  end

  create_table "boards", force: :cascade do |t|
    t.bigint "project_id"
    t.float "lat"
    t.float "lng"
    t.integer "avg_daily_views"
    t.float "width"
    t.float "height"
    t.integer "duration"
    t.integer "status", default: 0
    t.string "address"
    t.string "images"
    t.string "name"
    t.string "category"
    t.integer "base_earnings"
    t.string "face"
    t.string "access_token"
    t.string "api_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["project_id"], name: "index_boards_on_project_id"
    t.index ["slug"], name: "index_boards_on_slug", unique: true
  end

  create_table "boards_campaigns", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "board_id", null: false
    t.integer "status", default: 0, null: false
    t.index ["board_id", "campaign_id"], name: "index_boards_campaigns_on_board_id_and_campaign_id"
    t.index ["campaign_id", "board_id"], name: "index_boards_campaigns_on_campaign_id_and_board_id"
  end

  create_table "campaign_denials", force: :cascade do |t|
    t.bigint "campaign_id"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_campaign_denials_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.bigint "project_id"
    t.string "name"
    t.string "description"
    t.float "budget"
    t.integer "status", default: 0
    t.boolean "state", default: false, null: false
    t.string "decline_comment"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ad_id"
    t.string "slug"
    t.datetime "state_updated_at"
    t.index ["ad_id"], name: "index_campaigns_on_ad_id"
    t.index ["project_id"], name: "index_campaigns_on_project_id"
    t.index ["slug"], name: "index_campaigns_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "impressions", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "board_id"
    t.integer "cycles", default: 1
    t.datetime "created_at", null: false
    t.float "total_price"
    t.index ["board_id"], name: "index_impressions_on_board_id"
    t.index ["campaign_id"], name: "index_impressions_on_campaign_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "invoice_number"
    t.bigint "payment_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_invoices_on_payment_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "total"
    t.bigint "user_id"
    t.string "paid_with"
    t.string "express_token"
    t.string "express_payer_id"
    t.inet "ip"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "project_users", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_users_on_project_id"
    t.index ["user_id"], name: "index_project_users_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "reports", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id"
    t.string "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_reports_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "timezone"
    t.string "name"
    t.string "provider"
    t.string "avatar"
    t.float "balance", default: 0.0
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "roles"
    t.integer "credit_limit", default: 100
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ads", "projects"
  add_foreign_key "boards", "projects"
  add_foreign_key "campaign_denials", "campaigns"
  add_foreign_key "campaigns", "ads"
  add_foreign_key "campaigns", "projects"
  add_foreign_key "impressions", "boards"
  add_foreign_key "impressions", "campaigns"
  add_foreign_key "invoices", "payments"
  add_foreign_key "invoices", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "project_users", "projects"
  add_foreign_key "project_users", "users"
  add_foreign_key "reports", "projects"
end
