class ChangeNotesFileIdToString < ActiveRecord::Migration[7.1]
  def change
    remove_column :notes, :file_id, :integer
    add_column :notes, :file_id, :string
  end
end
