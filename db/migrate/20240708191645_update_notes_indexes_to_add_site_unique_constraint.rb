class UpdateNotesIndexesToAddSiteUniqueConstraint < ActiveRecord::Migration[7.1]
  def change
    add_reference :notes, :discourse_site, foreign_key: true

    remove_index :notes, column: %i[directory_id post_id]
    remove_index :notes, column: %i[directory_id topic_id]
    remove_index :notes, column: %i[directory_id topic_url]

    add_index :notes, %i[discourse_site_id post_id], unique: true
    add_index :notes, %i[discourse_site_id topic_id], unique: true
    add_index :notes, %i[discourse_site_id topic_url], unique: true
  end
end
