class CleanUpDirectoryIdIndexOnNotes < ActiveRecord::Migration[7.1]
  def change
    remove_index :notes, column: %i[directory_id title]
    add_index :notes, %i[directory_id title], unique: true
  end
end
