class AddPathColumnToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :path, :string, null: false
  end
end
