# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_27_231134) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.integer "transition", default: 0
    t.boolean "processed", default: false
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
    t.integer "duration", default: 10
    t.index ["project_id"], name: "index_ads_on_project_id"
    t.index ["slug"], name: "index_ads_on_slug", unique: true
  end

  create_table "ads_campaigns", id: false, force: :cascade do |t|
    t.bigint "ad_id", null: false
    t.bigint "campaign_id", null: false
    t.index ["ad_id", "campaign_id"], name: "index_ads_campaigns_on_ad_id_and_campaign_id"
    t.index ["campaign_id", "ad_id"], name: "index_ads_campaigns_on_campaign_id_and_ad_id"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "board_sales", force: :cascade do |t|
    t.bigint "board_id", null: false
    t.bigint "sale_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["board_id"], name: "index_board_sales_on_board_id"
    t.index ["sale_id"], name: "index_board_sales_on_sale_id"
  end

  create_table "boards", force: :cascade do |t|
    t.bigint "project_id"
    t.float "lat"
    t.float "lng"
    t.integer "avg_daily_views"
    t.float "width"
    t.float "height"
    t.integer "duration", default: 10
    t.integer "status", default: 0
    t.string "address"
    t.string "images"
    t.string "name"
    t.string "category"
    t.integer "base_earnings"
    t.string "face"
    t.string "access_token"
    t.string "api_token"
    t.string "ads_rotation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "qr"
    t.integer "social_class", default: 0
    t.string "default_images"
    t.string "aspect_ratio"
    t.time "start_time"
    t.time "end_time"
    t.integer "utc_offset"
    t.boolean "images_only", default: false
    t.integer "extra_percentage_earnings", default: 20
    t.string "mac_address"
    t.integer "displays_number", default: 1
    t.datetime "ads_rotation_updated_at"
    t.index ["project_id"], name: "index_boards_on_project_id"
    t.index ["slug"], name: "index_boards_on_slug", unique: true
  end

  create_table "boards_campaigns", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "board_id", null: false
    t.integer "status", default: 0, null: false
    t.float "cycle_price"
    t.bigint "sale_id"
    t.integer "remaining_impressions", default: 0
    t.index ["board_id", "campaign_id"], name: "index_boards_campaigns_on_board_id_and_campaign_id"
    t.index ["campaign_id", "board_id"], name: "index_boards_campaigns_on_campaign_id_and_board_id"
    t.index ["sale_id"], name: "index_boards_campaigns_on_sale_id"
  end

  create_table "campaign_denials", force: :cascade do |t|
    t.bigint "campaign_id"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_campaign_denials_on_campaign_id"
  end

  create_table "campaign_subscribers", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.string "name"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_campaign_subscribers_on_campaign_id"
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
    t.boolean "provider_campaign"
    t.integer "clasification", default: 0
    t.integer "minutes"
    t.integer "imp"
    t.string "analytics_token"
    t.string "link"
    t.integer "objective", default: 0
    t.integer "impression_count", default: 0
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

  create_table "impression_hours", force: :cascade do |t|
    t.time "start"
    t.time "end"
    t.integer "imp"
    t.integer "day"
    t.bigint "campaign_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_impression_hours_on_campaign_id"
  end

  create_table "impressions", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "board_id"
    t.integer "cycles", default: 1
    t.datetime "created_at", null: false
    t.float "total_price"
    t.index ["board_id"], name: "index_impressions_on_board_id"
    t.index ["campaign_id"], name: "index_impressions_on_campaign_id"
    t.index ["created_at", "board_id"], name: "index_impressions_on_created_at_and_board_id", unique: true
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

  create_table "notifications", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "actor_id"
    t.datetime "read_at"
    t.string "action"
    t.integer "notifiable_id"
    t.string "notifiable_type"
    t.integer "reference_id"
    t.string "reference_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sms", default: false
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
    t.float "transaction_fee"
    t.integer "status", default: 0
    t.string "spei_reference"
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
    t.integer "classification", default: 0
    t.string "available_campaign_types", default: "[\"budget\"]"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "provider_invoices", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "issuing_id"
    t.string "documents"
    t.bigint "campaign_id"
    t.string "comments"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_provider_invoices_on_campaign_id"
    t.index ["user_id"], name: "index_provider_invoices_on_user_id"
  end

  create_table "punches", id: :serial, force: :cascade do |t|
    t.integer "punchable_id", null: false
    t.string "punchable_type", limit: 20, null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "average_time", null: false
    t.integer "hits", default: 1, null: false
    t.index ["average_time"], name: "index_punches_on_average_time"
    t.index ["punchable_type", "punchable_id"], name: "punchable_index"
  end

  create_table "reports", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id"
    t.string "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.bigint "campaign_id"
    t.bigint "board_id"
    t.index ["board_id"], name: "index_reports_on_board_id"
    t.index ["campaign_id"], name: "index_reports_on_campaign_id"
    t.index ["project_id"], name: "index_reports_on_project_id"
  end

  create_table "sales", force: :cascade do |t|
    t.integer "percent"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shorteners", force: :cascade do |t|
    t.string "target_url"
    t.string "token"
    t.datetime "expires_at", default: "2031-01-25 21:00:16"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "qr"
  end

  create_table "user_activities", force: :cascade do |t|
    t.string "activity"
    t.integer "activeness_id"
    t.string "activeness_type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_activities_on_user_id"
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
    t.integer "credit_limit", default: 2000
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
    t.boolean "verified", default: true
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "phone_number"
    t.boolean "banned", default: false
    t.string "uid"
    t.string "business_type"
    t.string "company_name"
    t.string "work_position"
    t.string "payment_preference"
    t.integer "sign_in_count", default: 0, null: false
    t.string "captcha"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "official_id"
    t.string "business_name"
    t.string "street_1"
    t.string "street_2"
    t.string "city"
    t.string "state"
    t.integer "zip_code"
    t.string "country"
    t.string "rfc"
    t.string "business_code"
    t.string "official_business_name"
    t.string "website"
    t.string "phone"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_verifications_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ads", "projects"
  add_foreign_key "board_sales", "boards"
  add_foreign_key "board_sales", "sales"
  add_foreign_key "boards", "projects"
  add_foreign_key "boards_campaigns", "sales"
  add_foreign_key "campaign_denials", "campaigns"
  add_foreign_key "campaign_subscribers", "campaigns"
  add_foreign_key "campaigns", "ads"
  add_foreign_key "campaigns", "projects"
  add_foreign_key "impression_hours", "campaigns"
  add_foreign_key "impressions", "boards"
  add_foreign_key "impressions", "campaigns"
  add_foreign_key "invoices", "payments"
  add_foreign_key "invoices", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "project_users", "projects"
  add_foreign_key "project_users", "users"
  add_foreign_key "provider_invoices", "campaigns"
  add_foreign_key "provider_invoices", "users"
  add_foreign_key "reports", "boards"
  add_foreign_key "reports", "campaigns"
  add_foreign_key "reports", "projects"
  add_foreign_key "user_activities", "users"
  add_foreign_key "verifications", "users"
end
