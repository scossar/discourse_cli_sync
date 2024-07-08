class AddDescriptionToDiscourseCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_categories, :description, :text
  end
end
