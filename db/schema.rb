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

ActiveRecord::Schema[7.1].define(version: 2024_07_08_190717) do
  create_table "directories", force: :cascade do |t|
    t.string "path", null: false
    t.integer "discourse_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "discourse_site_id"
    t.index ["discourse_category_id"], name: "index_directories_on_discourse_category_id"
    t.index ["discourse_site_id", "path"], name: "index_directories_on_discourse_site_id_and_path", unique: true
    t.index ["discourse_site_id"], name: "index_directories_on_discourse_site_id"
  end

  create_table "discourse_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.boolean "read_restricted", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "discourse_id"
    t.integer "discourse_site_id"
    t.index ["discourse_site_id", "discourse_id"], name: "index_discourse_categories_on_site_and_discourse_id", unique: true
    t.index ["discourse_site_id", "name"], name: "index_discourse_categories_on_site_and_name", unique: true
    t.index ["discourse_site_id", "slug"], name: "index_discourse_categories_on_site_and_slug", unique: true
    t.index ["discourse_site_id"], name: "index_discourse_categories_on_discourse_site_id"
  end

  create_table "discourse_sites", force: :cascade do |t|
    t.string "domain", null: false
    t.string "iv"
    t.string "salt"
    t.string "encrypted_api_key"
    t.string "base_url", null: false
    t.string "vault_directory"
    t.string "discourse_username"
    t.string "site_tag"
    t.index ["domain", "discourse_username"], name: "index_discourse_sites_on_domain_and_discourse_username", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "local_only", default: false, null: false
    t.string "topic_url"
    t.integer "topic_id"
    t.integer "post_id"
    t.string "archetype", default: "regular", null: false
    t.integer "directory_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["directory_id", "post_id"], name: "index_notes_on_directory_id_and_post_id", unique: true
    t.index ["directory_id", "title"], name: "index_notes_on_directory_id_and_title", unique: true
    t.index ["directory_id", "topic_id"], name: "index_notes_on_directory_id_and_topic_id", unique: true
    t.index ["directory_id", "topic_url"], name: "index_notes_on_directory_id_and_topic_url", unique: true
    t.index ["directory_id"], name: "index_notes_on_directory_id"
  end

  add_foreign_key "directories", "discourse_categories"
  add_foreign_key "directories", "discourse_sites"
  add_foreign_key "discourse_categories", "discourse_sites"
  add_foreign_key "notes", "directories"
end
