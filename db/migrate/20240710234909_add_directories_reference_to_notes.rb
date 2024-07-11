class AddDirectoriesReferenceToNotes < ActiveRecord::Migration[7.1]
  def change
    add_reference :notes, :directory, index: true, foreign_key: true
  end
end
