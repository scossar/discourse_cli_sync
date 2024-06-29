class CreateNotesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.boolean :local_only, default: false, null: false
      t.string :topic_url
      t.integer :topic_id
      t.integer :post_id
      t.string :archetype, default: 'regular', null: false

      t.references :discourse_category, foreign_key: true
      t.references :directory, foreign_key: true

      t.timestamps
    end
    add_index :notes, %i[directory_id title], unique: true
    add_index :notes, :topic_url, unique: true
    add_index :notes, :topic_id, unique: true
    add_index :notes, :post_id, unique: true
  end
end
