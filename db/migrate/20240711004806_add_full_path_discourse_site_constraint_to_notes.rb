class AddFullPathDiscourseSiteConstraintToNotes < ActiveRecord::Migration[7.1]
  def change
    add_index :notes, %i[discourse_site_id full_path], unique: true
  end
end
