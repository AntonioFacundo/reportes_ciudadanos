# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_02_171828) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

# Could not dump table "alcaldias" because of following StandardError
#   Unknown type 'geometry(Polygon,4326)' for column 'boundary'


  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "sla_hours"
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "path"
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.text "auth_key", null: false
    t.datetime "created_at", null: false
    t.text "endpoint", null: false
    t.text "p256dh_key", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "endpoint"], name: "index_push_subscriptions_on_user_id_and_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "alcaldia_id"
    t.datetime "assigned_at"
    t.bigint "assignee_id"
    t.text "assignment_note"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.text "location_description"
    t.decimal "longitude", precision: 10, scale: 7
    t.datetime "read_at"
    t.boolean "reopened", default: false, null: false
    t.datetime "reporter_accepted_at"
    t.bigint "reporter_id", null: false
    t.text "reporter_rejection_note"
    t.text "resolution_note"
    t.datetime "resolved_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["alcaldia_id"], name: "index_reports_on_alcaldia_id"
    t.index ["assignee_id", "status"], name: "index_reports_on_assignee_id_and_status"
    t.index ["assignee_id"], name: "index_reports_on_assignee_id"
    t.index ["category_id"], name: "index_reports_on_category_id"
    t.index ["reporter_id", "status"], name: "index_reports_on_reporter_id_and_status"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "spatial_ref_sys", primary_key: "srid", id: :integer, default: nil, force: :cascade do |t|
    t.string "auth_name", limit: 256
    t.integer "auth_srid"
    t.string "proj4text", limit: 2048
    t.string "srtext", limit: 2048
    t.check_constraint "srid > 0 AND srid <= 998999", name: "spatial_ref_sys_srid_check"
  end

  create_table "system_audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}
    t.bigint "target_id"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_system_audit_logs_on_action"
    t.index ["actor_id"], name: "index_system_audit_logs_on_actor_id"
    t.index ["created_at"], name: "index_system_audit_logs_on_created_at"
    t.index ["target_type", "target_id"], name: "index_system_audit_logs_on_target_type_and_target_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "alcaldia_id"
    t.datetime "created_at", null: false
    t.string "email_address"
    t.bigint "manager_id"
    t.string "name"
    t.string "password_digest", null: false
    t.string "role", default: "citizen", null: false
    t.datetime "updated_at", null: false
    t.index ["alcaldia_id"], name: "index_users_on_alcaldia_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true, where: "(email_address IS NOT NULL)"
    t.index ["manager_id"], name: "index_users_on_manager_id"
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "reports", "alcaldias"
  add_foreign_key "reports", "categories"
  add_foreign_key "reports", "users", column: "assignee_id"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "system_audit_logs", "users", column: "actor_id"
  add_foreign_key "users", "alcaldias"
  add_foreign_key "users", "users", column: "manager_id"
end
