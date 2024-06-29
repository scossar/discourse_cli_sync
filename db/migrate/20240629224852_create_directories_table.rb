class CreateDirectoriesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :directories do |t|
      t.string :path, null: false
      t.string :archetype, default: 'regular', null: false
      t.references :discourse_category, foreign_key: true

      t.timestamps
    end
    add_index :directories, :path, unique: true
  end
end
