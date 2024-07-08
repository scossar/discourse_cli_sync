class InitialMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_sites do |t|
      t.string :domain, null: false
      t.string :url, null: false
      t.string :iv
      t.string :salt
      t.string :encrypted_api_key
      t.string :base_url, null: false
      t.string :vault_directory, null: false
      t.string :discourse_username, null: false

      t.timestamps
    end
    add_index :discourse_sites, %i[domain discourse_username], unique: true

    create_table :notes do |t|
      t.string :title, null: false
      t.boolean :local_only, default: false, null: false
      t.string :topic_url
      t.integer :topic_id
      t.integer :post_id

      t.references :discourse_site, foreign_key: true
      t.references :directory, foreign_key: true

      t.timestamps
    end
    add_index :notes, %i[discourse_site_id topic_url], unique: true
    add_index :notes, %i[discourse_site_id topic_id], unique: true
    add_index :notes, %i[discourse_site_id post_id], unique: true

    create_table :directories do |t|
      t.string :path, null: false

      t.references :discourse_site, foreign_key: true
      t.references :discourse_category, foreign_key: true

      t.timestamps
    end
    add_index :discourse_categories, %i[discourse_site_id path], unique: true

    create_table :discourse_categories do |t|
      t.string :name, null: false
      t.boolean :read_restricted, null: false
      t.text :description

      t.references :discourse_site, foreign_key: true

      t.timestamps
    end
    add_index :discourse_categories % i[discourse_site_id name], unique: true
  end
end
