class CreateDiscourseSitesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_sites do |t|
      t.string :domain, null: false
      t.string :url, null: false
      t.string :iv
      t.string :salt
      t.string :encrypted_api_key
      t.string :base_url, null: false
      t.string :vault_directory
      t.string :discourse_username
    end
    add_index :discourse_sites, %i[domain discourse_username], unique: true
  end
end
