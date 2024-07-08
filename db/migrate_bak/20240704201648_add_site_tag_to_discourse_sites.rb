class AddSiteTagToDiscourseSites < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_sites, :site_tag, :string
  end
end
