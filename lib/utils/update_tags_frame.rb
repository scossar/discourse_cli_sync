# frozen_string_literal: true

require_relative '../errors/errors'
require_relative '../models/note'
require_relative '../models/discourse_topic'
require_relative '../services/discourse_request'

module Discourse
  module Utils
    class UpdateTagsFrame
      def initialize(discourse_site:, api_key:)
        @discourse_site = discourse_site
        @api_key = api_key
        @site_tag = @discourse_site.site_tag
        @client = Discourse::DiscourseRequest.new(@discourse_site, @api_key)
      end

      def update_site_tag(topics:, old_site_tag:)
        CLI::UI::Frame.open("Tagging all Discourse topics with {{bold:#{@site_tag}}}") do
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end
          topics.each do |topic|
            update_topic_tags(spin_group:,
                              discourse_topic: topic,
                              tags_to_add: tags_to_array(@site_tag),
                              tags_to_remove: tags_to_array(old_site_tag))
          end
        end
      end

      private

      def update_topic_tags(spin_group:, discourse_topic:, tags_to_add:, tags_to_remove:)
        note = discourse_topic.note
        new_tags_str = tags_to_string(tags_to_add)
        current_tags = tags_to_array(discourse_topic.tags)
        tags = consolidate_tags(current_tags:, tags_to_add:, tags_to_remove:)
        spin_group.add("Adding {{bold:#{new_tags_str}}} to {{green:#{note.title}}}") do |spinner|
          update_topic(discourse_topic:, tags:)
          update_discourse_topic_entry(discourse_topic:, tags:)
          spinner.update_title("Added {{bold:#{new_tags_str}}} to {{green:#{note.title}}}")
        end
        spin_group.wait
      end

      def consolidate_tags(current_tags:, tags_to_add:, tags_to_remove:)
        updated_tags = current_tags + tags_to_add
        updated_tags -= tags_to_remove
        updated_tags.uniq
      end

      def update_topic(discourse_topic:, tags:)
        topic_id = discourse_topic.topic_id
        @client.update_topic(topic_id:,
                             params: { tags:,
                                       keep_existing_draft: true,
                                       skip_validations: true }).tap do |result|
          unless result
            raise Discourse::Errors::BaseError,
                  "Unable to update topic entry for topic_id: #{topic_id}"
          end
        end
        update_discourse_topic_entry(discourse_topic:, tags:)
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Unable to update topic entry: #{e.message}"
      end

      def update_discourse_topic_entry(discourse_topic:, tags:)
        tags_str = tags_to_string(tags)
        discourse_topic.update(tags: tags_str).tap do |response|
          raise Discourse::Errors::BaseError, 'Unable to update topic entry' unless response
        end
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error updating topic entry: #{e.message}"
      end

      def tags_to_array(tags)
        tags.is_a?(String) ? tags.split('|') : Array(tags)
      end

      def tags_to_string(tags)
        tags.join('|')
      end
    end
  end
end
