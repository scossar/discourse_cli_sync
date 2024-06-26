class CreateInitialSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :discourse_id, null: false
      t.boolean :read_restricted, default: false
      t.timestamps
    end

    add_index :discourse_categories, :discourse_id, unique: true

    create_table :directories do |t|
      t.string :path, null: false
      t.string :archetype, null: false, default: 'regular'
      t.references :discourse_category, foreign_key: true
      t.timestamps
    end

    add_index :directories, :path, unique: true

    create_table :notes do |t|
      t.string :title, null: false
      t.boolean :private, default: false
      t.boolean :local_only, default: false
      t.references :directory, null: false, foreign_key: true
      t.timestamps
    end

    add_index :notes, :title, unique: true

    create_table :discourse_topics do |t|
      t.string :discourse_url, null: false
      t.integer :discourse_id, null: false
      t.integer :discourse_post_id, null: false
      t.references :note, null: false, foreign_key: true
      t.timestamps
    end

    add_index :discourse_topics, :discourse_url, unique: true
    add_index :discourse_topics, :discourse_id, unique: true
    add_index :discourse_topics, :discourse_post_id, unique: true
  end
end
