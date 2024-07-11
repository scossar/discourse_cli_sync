class AddPathToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :full_path, :string, null: false

    add_index :notes, %i[discourse_site_id path], unique: true
  end
end
