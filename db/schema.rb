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

ActiveRecord::Schema[7.1].define(version: 2023_12_05_091857) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.string "guid"
    t.integer "wage_cents", default: 0, null: false
    t.string "wage_currency", default: "EUR", null: false
    t.date "start_at", null: false
    t.date "end_at", null: false
    t.float "average_weekly_hours", default: 0.0, null: false
    t.string "archive_number"
    t.datetime "company_signed_at"
    t.datetime "user_signed_at"
    t.bigint "user_id", null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archive_number"], name: "index_contracts_on_archive_number", unique: true
    t.index ["company_id"], name: "index_contracts_on_company_id"
    t.index ["guid"], name: "index_contracts_on_guid", unique: true, where: "(guid IS NOT NULL)"
    t.index ["user_id"], name: "index_contracts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "contracts", "companies", on_delete: :nullify
  add_foreign_key "contracts", "users", on_delete: :cascade
end
