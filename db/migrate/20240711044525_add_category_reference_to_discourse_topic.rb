class AddCategoryReferenceToDiscourseTopic < ActiveRecord::Migration[7.1]
  def change
    add_reference :discourse_topics, :discourse_category, index: true, foreign_key: true
  end
end
