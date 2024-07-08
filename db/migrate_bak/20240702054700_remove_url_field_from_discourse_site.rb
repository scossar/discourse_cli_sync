class RemoveUrlFieldFromDiscourseSite < ActiveRecord::Migration[7.1]
  def change
    remove_column :discourse_sites, :url
  end
end
