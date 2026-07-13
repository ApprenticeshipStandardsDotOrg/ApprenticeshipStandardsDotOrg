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

ActiveRecord::Schema[8.1].define(version: 2026_07_13_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "competencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "competency_options_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "sort_order"
    t.string "title"
    t.datetime "updated_at", null: false
    t.uuid "work_process_id", null: false
    t.index ["work_process_id"], name: "index_competencies_on_work_process_id"
  end

  create_table "competency_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "sort_order", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_competency_options_on_resource"
  end

  create_table "contact_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.string "organization"
    t.datetime "updated_at", null: false
  end

  create_table "courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "hours"
    t.uuid "organization_id"
    t.string "title"
    t.decimal "units"
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_courses_on_organization_id"
  end

  create_table "data_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.uuid "import_id"
    t.uuid "occupation_standard_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["import_id"], name: "index_data_imports_on_import_id"
    t.index ["occupation_standard_id"], name: "index_data_imports_on_occupation_standard_id"
    t.index ["user_id"], name: "index_data_imports_on_user_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assignee_id"
    t.integer "courtesy_notification", default: 0
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.uuid "parent_id", null: false
    t.string "parent_type", null: false
    t.datetime "processed_at", precision: nil
    t.text "processing_errors"
    t.boolean "public_document", default: false, null: false
    t.datetime "redacted_at", precision: nil
    t.integer "status", default: 0, null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_imports_on_assignee_id"
    t.index ["parent_type", "parent_id"], name: "index_imports_on_parent"
    t.index ["processed_at"], name: "index_imports_on_processed_at"
  end

  create_table "industries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "prefix"
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "noticed_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.jsonb "params"
    t.uuid "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.datetime "read_at", precision: nil
    t.uuid "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "occupation_standards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "apprenticeship_to_journeyworker_ratio"
    t.datetime "created_at", null: false
    t.string "existing_title"
    t.uuid "industry_id"
    t.date "latest_update_date"
    t.integer "national_standard_type"
    t.uuid "occupation_id"
    t.integer "ojt_hours_max"
    t.integer "ojt_hours_min"
    t.integer "ojt_type"
    t.string "onet_code"
    t.uuid "organization_id"
    t.integer "probationary_period_months"
    t.string "rapids_code"
    t.uuid "registration_agency_id"
    t.date "registration_date"
    t.integer "rsi_hours_max"
    t.integer "rsi_hours_min"
    t.boolean "sample_set", default: false, null: false
    t.integer "status", default: 0, null: false
    t.integer "term_months"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["industry_id"], name: "index_occupation_standards_on_industry_id"
    t.index ["occupation_id"], name: "index_occupation_standards_on_occupation_id"
    t.index ["organization_id"], name: "index_occupation_standards_on_organization_id"
    t.index ["registration_agency_id"], name: "index_occupation_standards_on_registration_agency_id"
    t.index ["sample_set"], name: "index_occupation_standards_on_sample_set"
  end

  create_table "occupations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "competency_based_hours"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "hybrid_hours_max"
    t.integer "hybrid_hours_min"
    t.uuid "onet_id"
    t.string "rapids_code"
    t.integer "time_based_hours"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["onet_id"], name: "index_occupations_on_onet_id"
  end

  create_table "onet_mappings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "next_version_onet_id", null: false
    t.uuid "onet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["next_version_onet_id"], name: "index_onet_mappings_on_next_version_onet_id"
    t.index ["onet_id", "next_version_onet_id"], name: "index_onet_mappings_on_onet_id_and_next_version_onet_id", unique: true
  end

  create_table "onets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "related_job_titles", default: [], array: true
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["code"], name: "index_onets_on_code"
    t.index ["version", "code"], name: "index_onets_on_version_and_code", unique: true
  end

  create_table "open_ai_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "import_id", null: false
    t.uuid "occupation_standard_id"
    t.json "response"
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_open_ai_imports_on_import_id"
    t.index ["occupation_standard_id"], name: "index_open_ai_imports_on_occupation_standard_id"
  end

  create_table "open_ai_prompts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "default", default: false, null: false
    t.string "name", null: false
    t.text "prompt", null: false
    t.datetime "updated_at", null: false
    t.index ["default"], name: "index_open_ai_prompts_on_default", unique: true, where: "(\"default\" = true)"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "organization_type"
    t.string "sponsor_number"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registration_agencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "agency_type"
    t.datetime "created_at", null: false
    t.uuid "state_id"
    t.datetime "updated_at", null: false
    t.index ["state_id", "agency_type"], name: "index_registration_agencies_on_state_id_and_agency_type", unique: true
    t.index ["state_id"], name: "index_registration_agencies_on_state_id"
  end

  create_table "related_instructions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.uuid "course_id"
    t.datetime "created_at", null: false
    t.uuid "default_course_id"
    t.string "description"
    t.boolean "elective"
    t.integer "hours"
    t.uuid "occupation_standard_id", null: false
    t.uuid "organization_id"
    t.integer "sort_order"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_related_instructions_on_course_id"
    t.index ["default_course_id"], name: "index_related_instructions_on_default_course_id"
    t.index ["occupation_standard_id"], name: "index_related_instructions_on_occupation_standard_id"
    t.index ["organization_id"], name: "index_related_instructions_on_organization_id"
  end

  create_table "standards_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "courtesy_notification", default: 0
    t.datetime "created_at", null: false
    t.string "email"
    t.jsonb "metadata", default: {}, null: false
    t.string "name"
    t.text "notes"
    t.string "organization"
    t.boolean "public_document", default: false, null: false
    t.string "source_url"
    t.datetime "updated_at", null: false
  end

  create_table "states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "surveys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "organization", null: false
    t.datetime "updated_at", null: false
  end

  create_table "synonyms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "synonyms", null: false
    t.datetime "updated_at", null: false
    t.string "word", null: false
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "text_representations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.uuid "data_import_id", null: false
    t.string "document_sha"
    t.datetime "updated_at", null: false
    t.index ["data_import_id"], name: "index_text_representations_on_data_import_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_created_at"
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at"
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "invited_by_id"
    t.string "invited_by_type"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wage_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_in_months"
    t.integer "minimum_hours"
    t.uuid "occupation_standard_id", null: false
    t.decimal "ojt_percentage"
    t.integer "rsi_hours"
    t.integer "sort_order"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["occupation_standard_id"], name: "index_wage_steps_on_occupation_standard_id"
  end

  create_table "word_replacements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "replacement", default: "****"
    t.datetime "updated_at", null: false
    t.string "word", null: false
  end

  create_table "work_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "competencies_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "default_hours"
    t.string "description"
    t.integer "maximum_hours"
    t.integer "minimum_hours"
    t.uuid "occupation_standard_id", null: false
    t.integer "sort_order"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["occupation_standard_id"], name: "index_work_processes_on_occupation_standard_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_keys", "users"
  add_foreign_key "competencies", "work_processes"
  add_foreign_key "courses", "organizations"
  add_foreign_key "data_imports", "imports"
  add_foreign_key "data_imports", "occupation_standards"
  add_foreign_key "data_imports", "users"
  add_foreign_key "imports", "users", column: "assignee_id"
  add_foreign_key "occupation_standards", "industries"
  add_foreign_key "occupation_standards", "occupations"
  add_foreign_key "occupation_standards", "organizations"
  add_foreign_key "occupation_standards", "registration_agencies"
  add_foreign_key "occupations", "onets"
  add_foreign_key "onet_mappings", "onets"
  add_foreign_key "onet_mappings", "onets", column: "next_version_onet_id"
  add_foreign_key "open_ai_imports", "imports"
  add_foreign_key "open_ai_imports", "occupation_standards"
  add_foreign_key "registration_agencies", "states"
  add_foreign_key "related_instructions", "courses"
  add_foreign_key "related_instructions", "courses", column: "default_course_id"
  add_foreign_key "related_instructions", "occupation_standards"
  add_foreign_key "related_instructions", "organizations"
  add_foreign_key "text_representations", "data_imports"
  add_foreign_key "wage_steps", "occupation_standards"
  add_foreign_key "work_processes", "occupation_standards"
end
