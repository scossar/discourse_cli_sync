class UpdateUniqueConstraintsOnDiscourseCategories < ActiveRecord::Migration[7.1]
  def change
    remove_index :discourse_categories, name: 'index_discourse_categories_on_discourse_id'
    remove_index :discourse_categories, name: 'index_discourse_categories_on_name'
    remove_index :discourse_categories, name: 'index_discourse_categories_on_slug'

    add_index :discourse_categories, %i[discourse_site_id discourse_id], unique: true,
                                                                         name: 'index_discourse_categories_on_site_and_discourse_id'
    add_index :discourse_categories, %i[discourse_site_id name], unique: true,
                                                                 name: 'index_discourse_categories_on_site_and_name'
    add_index :discourse_categories, %i[discourse_site_id slug], unique: true,
                                                                 name: 'index_discourse_categories_on_site_and_slug'
  end
end
