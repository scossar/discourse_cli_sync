class AddDiscourseSiteReferenceToDiscourseCategories < ActiveRecord::Migration[7.1]
  def change
    add_reference :discourse_categories, :discourse_site, foreign_key: true
  end
end
