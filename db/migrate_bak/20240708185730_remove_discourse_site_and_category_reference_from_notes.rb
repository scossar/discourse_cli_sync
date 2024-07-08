class RemoveDiscourseSiteAndCategoryReferenceFromNotes < ActiveRecord::Migration[7.1]
  def change
    remove_reference :notes, :discourse_site
    remove_reference :notes, :discourse_category
  end
end
