class RemoveUniqueConstraintsFromNotes < ActiveRecord::Migration[7.1]
  def change
    remove_index :notes, column: %i[discourse_site_id topic_url]
    remove_index :notes, column: %i[discourse_site_id topic_id]
    remove_index :notes, column: %i[discourse_site_id post_id]
  end
end
