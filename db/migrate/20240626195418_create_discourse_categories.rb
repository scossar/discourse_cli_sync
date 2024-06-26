class CreateDiscourseCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :discourse_id, null: false
      t.boolean :read_restricted, null: false
    end

    add_index :discourse_categories, :name, unique: true
    add_index :discourse_categories, :discourse_id, unique: true
  end
end
