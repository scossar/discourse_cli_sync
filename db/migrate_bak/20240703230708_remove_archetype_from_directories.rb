class RemoveArchetypeFromDirectories < ActiveRecord::Migration[7.1]
  def change
    remove_column :directories, :archetype
  end
end
