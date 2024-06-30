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

ActiveRecord::Schema[7.1].define(version: 2024_06_29_235702) do
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
    t.boolean "read_restricted", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_discourse_categories_on_name", unique: true
    t.index ["slug"], name: "index_discourse_categories_on_slug", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "local_only", default: false, null: false
    t.string "topic_url"
    t.integer "topic_id"
    t.integer "post_id"
    t.string "archetype", default: "regular", null: false
    t.integer "discourse_category_id"
    t.integer "directory_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["directory_id", "title"], name: "index_notes_on_directory_id_and_title", unique: true
    t.index ["directory_id"], name: "index_notes_on_directory_id"
    t.index ["discourse_category_id"], name: "index_notes_on_discourse_category_id"
    t.index ["post_id"], name: "index_notes_on_post_id", unique: true
    t.index ["topic_id"], name: "index_notes_on_topic_id", unique: true
    t.index ["topic_url"], name: "index_notes_on_topic_url", unique: true
  end

  add_foreign_key "directories", "discourse_categories"
  add_foreign_key "notes", "directories"
  add_foreign_key "notes", "discourse_categories"
end
