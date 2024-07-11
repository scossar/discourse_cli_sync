class AddDiscourseSitesReferenceToNotes < ActiveRecord::Migration[7.1]
  def change
    add_reference :notes, :discourse_site, index: true, foreign_key: true
  end
end
