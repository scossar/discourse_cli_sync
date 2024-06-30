class CreateEncryptedCredentialsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :encrypted_credentials do |t|
      t.string :host, null: false
      t.string :iv, null: false
      t.string :salt, null: false
      t.string :encrypted_api_key, null: false

      t.timestamps
    end

    add_index :encrypted_credentials, :host, unique: true
  end
end
