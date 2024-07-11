class FixFullPathIndexOnNotes < ActiveRecord::Migration[7.1]
  def change
    remove_index :notes, name: 'index_notes_on_discourse_site_id_and_path'
  end
end
