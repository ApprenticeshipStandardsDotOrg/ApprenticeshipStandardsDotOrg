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

ActiveRecord::Schema[7.0].define(version: 2023_01_23_173947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "competencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "work_process_id", null: false
    t.string "title"
    t.text "description"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["work_process_id"], name: "index_competencies_on_work_process_id"
  end

  create_table "competency_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "resource_type", null: false
    t.uuid "resource_id", null: false
    t.string "title", null: false
    t.integer "sort_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_competency_options_on_resource"
  end

  create_table "courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "code"
    t.decimal "units"
    t.integer "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_data_imports_on_user_id"
  end

  create_table "file_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_storage_attachment_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_storage_attachment_id"], name: "index_file_imports_on_active_storage_attachment_id"
  end

  create_table "occupation_standards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "occupation_id"
    t.string "url"
    t.uuid "registration_agency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occupation_id"], name: "index_occupation_standards_on_occupation_id"
    t.index ["registration_agency_id"], name: "index_occupation_standards_on_registration_agency_id"
  end

  create_table "occupations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rapids_code"
    t.integer "time_based_hours"
    t.int4range "hybrid_hours"
    t.integer "competency_based_hours"
    t.uuid "onet_code_id"
    t.index ["onet_code_id"], name: "index_occupations_on_onet_code_id"
  end

  create_table "onet_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "unique_code", unique: true
  end

  create_table "registration_agencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "state_id", null: false
    t.integer "agency_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id", "agency_type"], name: "index_registration_agencies_on_state_id_and_agency_type", unique: true
    t.index ["state_id"], name: "index_registration_agencies_on_state_id"
  end

  create_table "related_instructions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.integer "hours"
    t.boolean "elective"
    t.integer "sort_order"
    t.uuid "occupation_standard_id", null: false
    t.integer "default_course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "course_id"
    t.index ["course_id"], name: "index_related_instructions_on_course_id"
    t.index ["occupation_standard_id"], name: "index_related_instructions_on_occupation_standard_id"
  end

  create_table "standards_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "organization"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.integer "role", default: 0, null: false
    t.string "name"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wage_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "occupation_standard_id", null: false
    t.integer "sort_order"
    t.string "title"
    t.integer "minimum_hours"
    t.decimal "ojt_percentage"
    t.integer "duration_in_months"
    t.integer "rsi_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occupation_standard_id"], name: "index_wage_steps_on_occupation_standard_id"
  end

  create_table "work_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.uuid "occupation_standard_id", null: false
    t.integer "minimum_hours"
    t.integer "maximum_hours"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_hours"
    t.index ["occupation_standard_id"], name: "index_work_processes_on_occupation_standard_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "competencies", "work_processes"
  add_foreign_key "data_imports", "users"
  add_foreign_key "file_imports", "active_storage_attachments"
  add_foreign_key "occupation_standards", "occupations"
  add_foreign_key "occupation_standards", "registration_agencies"
  add_foreign_key "occupations", "onet_codes"
  add_foreign_key "registration_agencies", "states"
  add_foreign_key "related_instructions", "courses"
  add_foreign_key "related_instructions", "occupation_standards"
  add_foreign_key "wage_steps", "occupation_standards"
  add_foreign_key "work_processes", "occupation_standards"
end
