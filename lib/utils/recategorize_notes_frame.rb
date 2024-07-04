# frozen_string_literal: true

require_relative '../models/note'
require_relative '../services/discourse_request'

module Discourse
  module Utils
    class RecategorizeNotesFrame
      class << self
        def call(directory:, discourse_site:, api_key:)
          @directory = directory
          @discourse_site = discourse_site
          @api_key = api_key
          @client = Discourse::DiscourseRequest.new(@discourse_site, @api_key)
          recategorize_notes
        end

        private

        def recategorize_notes
          notes = Discourse::Note.where(directory: @directory)
          category = @directory.discourse_category
          CLI::UI::Frame.open("Moving #{notes.count} notes to #{category.name}") do
            topics_task(notes, category)
          end
        end

        def topics_task(notes, category)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end
          notes.each do |note|
            title = note.title
            topic_id = note.topic_id
            spin_group.add("Moving #{title}") do |spinner|
              @client.update_topic(topic_id:,
                                   params: {
                                     category_id: category.discourse_id,
                                     keep_existing_draft: true,
                                     skip_validations: true
                                   })
              spinner.update_title("Moved #{title} to #{category.name}")
            end
            spin_group.wait
          end
        end
      end
    end
  end
end
