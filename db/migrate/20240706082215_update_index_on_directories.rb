class UpdateIndexOnDirectories < ActiveRecord::Migration[7.1]
  def change
    remove_index :directories, column: %i[path]
    add_index :directories, %i[discourse_site_id path], unique: true
  end
end
