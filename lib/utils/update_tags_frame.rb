# frozen_string_literal: true

require_relative '../models/note'
require_relative '../services/discourse_request'

module Discourse
  module Utils
    class UpdateTagsFrame
      class << self
        def call(discourse_site:, api_key:)
          @discourse_site = discourse_site
          @api_key = api_key
          @client = Discourse::DiscourseRequest.new(@discourse_site, @api_key)
          update_tags
        end

        private

        def update_tags
          notes = Discourse::Note.all
          CLI::UI::Frame.open("Adding #{@discourse_site.site_tag} to all published notes") do
            tags_task(notes)
          end
        end

        def tags_task(notes)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end
          notes.each do |note|
            title = note.title
            topic_id = note.topic_id
            tag = @discourse_site.site_tag
            spin_group.add("Adding #{tag} to #{title} topic") do |spinner|
              @client.update_topic(topic_id:,
                                   params: {
                                     tags: [tag],
                                     keep_existing_draft: true,
                                     skip_validations: true
                                   })
              spinner.update_title("Added #{tag} to #{title} topic")
            end
            spin_group.wait
          end
        end
      end
    end
  end
end
