class AddFileIdToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :file_id, :integer
  end
end
