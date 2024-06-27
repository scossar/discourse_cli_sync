class AddBaseUrlToEncryptedCredentials < ActiveRecord::Migration[7.1]
  def change
    add_column :encrypted_credentials, :base_url, :string, null: false
  end
end
