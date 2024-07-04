# frozen_string_literal: true

require_relative '../models/note'
require_relative '../services/discourse_request'

require_relative 'logger'

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
          CLI::UI::Frame.open("Recategorizing #{notes.count} notes to #{category.name}") do
            spin_group = CLI::UI::SpinGroup.new

            spin_group.failure_debrief do |_title, exception|
              puts CLI::UI.fmt "  #{exception}"
            end

            notes.each do |note|
              title = note.title
              topic_id = note.topic_id
              spin_group.add("Recategorizing #{title}") do |spinner|
                Discourse::Utils::Logger.debug("topic_id: #{topic_id}, category_id: #{category.discourse_id}")
                @client.update_topic(topic_id:, category_id: category.discourse_id)
                spinner.update_title("Recategorized #{title} to #{category.name}")
              end
              spin_group.wait
            end
          end
        end
      end
    end
  end
end
