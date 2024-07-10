class CreateDiscourseTopicsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_topics do |t|
      t.string :topic_url
      t.integer :topic_id
      t.integer :post_id
      t.boolean :local_only, default: false, null: false

      t.references :discourse_site, foreign_key: true
      t.references :directory, foreign_key: true
      t.references :note, foreign_key: true

      t.timestamps
    end
    add_index :discourse_topics, %i[discourse_site_id topic_url], unique: true
    add_index :discourse_topics, %i[discourse_site_id topic_id], unique: true
    add_index :discourse_topics, %i[discourse_site_id post_id], unique: true
    add_index :discourse_topics, %i[discourse_site_id note_id], unique: true
  end
end
