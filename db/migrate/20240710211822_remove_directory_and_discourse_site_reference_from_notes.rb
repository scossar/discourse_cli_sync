class RemoveDirectoryAndDiscourseSiteReferenceFromNotes < ActiveRecord::Migration[7.1]
  def change
    remove_column :notes, :topic_url
    remove_column :notes, :topic_id
    remove_column :notes, :post_id

    remove_reference :notes, :directory, index: true, foreign_key: true
    remove_reference :notes, :discourse_site, index: true, foreign_key: true
  end
end
