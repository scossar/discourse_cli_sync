class AddDiscourseSiteReferenceToNotes < ActiveRecord::Migration[7.1]
  def change
    add_reference :notes, :discourse_site, foreign_key: true
  end
end
