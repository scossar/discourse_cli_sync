class RemoveDirectoryAndSiteReferenceFromNotesAgain < ActiveRecord::Migration[7.1]
  def change
    remove_index :notes, name: 'index_notes_on_discourse_site_id_and_full_path'
    remove_reference :notes, :directory, index: true, foreign_key: true
    remove_reference :notes, :discourse_site, index: true, foreign_key: true
  end
end
