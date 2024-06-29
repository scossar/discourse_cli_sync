class CreateDiscourseTopicsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_topics do |t|
      t.string :url, null: false
      t.integer :topic_id, null: false
      t.integer :post_id, null: false
      t.string :archetype, default: 'regular', null: false
      t.references :note, foreign_key: true
      t.references :discourse_category, foreign_key: true

      t.timestamps
    end
    add_index :discourse_topics, :url, unique: true
    add_index :discourse_topics, :topic_id, unique: true
    add_index :discourse_topics, :post_id, unique: true
  end
end
