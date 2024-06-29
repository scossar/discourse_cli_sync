class CreateNotesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.boolean :local_only, null: false, default: false
      t.references :directory, foreign_key: true

      t.timestamps
    end
    add_index :notes, %i[directory_id title], unique: true
  end
end
