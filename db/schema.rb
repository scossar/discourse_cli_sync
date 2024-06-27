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

ActiveRecord::Schema[7.1].define(version: 2024_06_27_090543) do
  create_table "directories", force: :cascade do |t|
    t.string "path", null: false
    t.string "archetype", default: "regular", null: false
    t.integer "discourse_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discourse_category_id"], name: "index_directories_on_discourse_category_id"
    t.index ["path"], name: "index_directories_on_path", unique: true
  end

  create_table "discourse_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "discourse_id", null: false
    t.boolean "read_restricted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discourse_id"], name: "index_discourse_categories_on_discourse_id", unique: true
  end

  create_table "discourse_topics", force: :cascade do |t|
    t.string "discourse_url", null: false
    t.integer "discourse_id", null: false
    t.integer "discourse_post_id", null: false
    t.integer "note_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discourse_id"], name: "index_discourse_topics_on_discourse_id", unique: true
    t.index ["discourse_post_id"], name: "index_discourse_topics_on_discourse_post_id", unique: true
    t.index ["discourse_url"], name: "index_discourse_topics_on_discourse_url", unique: true
    t.index ["note_id"], name: "index_discourse_topics_on_note_id"
  end

  create_table "encrypted_credentials", force: :cascade do |t|
    t.string "encrypted_api_key", null: false
    t.string "salt", null: false
    t.string "iv", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "base_url", null: false
  end

  create_table "notes", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "private", default: false
    t.boolean "local_only", default: false
    t.integer "directory_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["directory_id"], name: "index_notes_on_directory_id"
    t.index ["title"], name: "index_notes_on_title", unique: true
  end

  add_foreign_key "directories", "discourse_categories"
  add_foreign_key "discourse_topics", "notes"
  add_foreign_key "notes", "directories"
end
