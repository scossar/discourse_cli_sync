class AddDiscourseIdToDiscourseCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_categories, :discourse_id, :integer

    add_index :discourse_categories, %i[discourse_site_id discourse_id]
  end
end
