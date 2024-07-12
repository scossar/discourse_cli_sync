class AddTagsColumnToDiscourseTopics < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_topics, :tags, :text
  end
end
