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

ActiveRecord::Schema[8.0].define(version: 2024_11_18_190826) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "page_views", force: :cascade do |t|
    t.text "url", null: false
    t.text "referrer"
    t.datetime "created_at", null: false
    t.string "digest", limit: 32, null: false
    t.index ["created_at"], name: "index_page_views_on_created_at"
    t.index ["digest"], name: "index_page_views_on_digest", unique: true
    t.index ["referrer", "url", "created_at"], name: "index_page_views_on_referrer_and_url_and_created_at"
    t.index ["url", "created_at"], name: "index_page_views_on_url_and_created_at"
  end
end
