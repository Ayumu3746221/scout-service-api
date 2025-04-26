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

ActiveRecord::Schema[8.0].define(version: 2025_04_26_100429) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "address"
    t.bigint "industry_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["industry_id"], name: "index_companies_on_industry_id"
  end

  create_table "industries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_posting_industries", force: :cascade do |t|
    t.bigint "job_posting_id", null: false
    t.bigint "industry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["industry_id"], name: "index_job_posting_industries_on_industry_id"
    t.index ["job_posting_id", "industry_id"], name: "index_job_posting_industries_on_job_posting_id_and_industry_id", unique: true
    t.index ["job_posting_id"], name: "index_job_posting_industries_on_job_posting_id"
  end

  create_table "job_posting_skills", force: :cascade do |t|
    t.bigint "job_posting_id", null: false
    t.bigint "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_posting_id", "skill_id"], name: "index_job_posting_skills_on_job_posting_id_and_skill_id", unique: true
    t.index ["job_posting_id"], name: "index_job_posting_skills_on_job_posting_id"
    t.index ["skill_id"], name: "index_job_posting_skills_on_skill_id"
  end

  create_table "job_postings", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title", null: false
    t.text "description"
    t.text "requirements"
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_job_postings_on_company_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "content"
    t.boolean "is_read", default: false
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.string "notification_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "recruiters", primary_key: "user_id", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_recruiters_on_company_id"
    t.index ["user_id"], name: "index_recruiters_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_industries", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "industry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["industry_id"], name: "index_student_industries_on_industry_id"
    t.index ["student_id", "industry_id"], name: "index_student_industries_on_student_id_and_industry_id", unique: true
    t.index ["student_id"], name: "index_student_industries_on_student_id"
  end

  create_table "student_skills", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_id"], name: "index_student_skills_on_skill_id"
    t.index ["student_id", "skill_id"], name: "index_student_skills_on_student_id_and_skill_id", unique: true
    t.index ["student_id"], name: "index_student_skills_on_student_id"
  end

  create_table "students", primary_key: "user_id", force: :cascade do |t|
    t.string "name", null: false
    t.text "introduce"
    t.integer "graduation_year"
    t.string "school"
    t.string "portfolio_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "companies", "industries"
  add_foreign_key "job_posting_industries", "industries"
  add_foreign_key "job_posting_industries", "job_postings"
  add_foreign_key "job_posting_skills", "job_postings"
  add_foreign_key "job_posting_skills", "skills"
  add_foreign_key "job_postings", "companies"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "recruiters", "companies"
  add_foreign_key "recruiters", "users"
  add_foreign_key "student_industries", "industries"
  add_foreign_key "student_industries", "users", column: "student_id"
  add_foreign_key "student_skills", "skills"
  add_foreign_key "student_skills", "users", column: "student_id"
  add_foreign_key "students", "users"
end
