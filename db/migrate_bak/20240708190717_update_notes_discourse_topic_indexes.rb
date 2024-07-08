class UpdateNotesDiscourseTopicIndexes < ActiveRecord::Migration[7.1]
  def change
    remove_index :notes, column: %i[post_id]
    remove_index :notes, column: %i[topic_id]
    remove_index :notes, column: %i[topic_url]

    add_index :notes, %i[directory_id post_id], unique: true
    add_index :notes, %i[directory_id topic_id], unique: true
    add_index :notes, %i[directory_id topic_url], unique: true
  end
end
