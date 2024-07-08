class DropEncryptedCredentialsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :encrypted_credentials
  end
end
