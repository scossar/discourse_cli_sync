class AddTagsColumnToDirectories < ActiveRecord::Migration[7.1]
  def change
    add_column :directories, :tags, :text
  end
end
