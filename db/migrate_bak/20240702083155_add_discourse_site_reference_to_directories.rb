class AddDiscourseSiteReferenceToDirectories < ActiveRecord::Migration[7.1]
  def change
    add_reference :directories, :discourse_site, foreign_key: true
  end
end
