# frozen_string_literal: true

require_relative '../models/note'
require_relative '../services/discourse_request'

module Discourse
  module Utils
    class RecategorizeNotesFrame
      class << self
        def call(directory:, api_key:)
          @directory = directory
          @discourse_site = @directory.discourse_site
          @api_key = api_key
          @client = Discourse::DiscourseRequest.new(@discourse_site, @api_key)
          recategorize_topics
        end

        private

        def recategorize_topics
          topics = Discourse::DiscourseTopic.where(directory: @directory)
          return if topics.empty?

          category = @directory.discourse_category
          CLI::UI::Frame.open("Moving #{topics.count} topics to #{category.name}") do
            topics_task(topics, category)
          end
        end

        def topics_task(topics, category)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end
          topics.each do |topic|
            note = topic.note
            title = note.title
            topic_id = topic.topic_id
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
