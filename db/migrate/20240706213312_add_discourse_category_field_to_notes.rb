class AddDiscourseCategoryFieldToNotes < ActiveRecord::Migration[7.1]
  def change
    add_reference :notes, :discourse_category, foreign_key: true
  end
end
