# frozen_string_literal: true

require_relative 'discourse_request'
require_relative '../errors/errors'
require_relative '../models/note'

module Discourse
  module Services
    class InternalLinkHandler
      def initialize(api_key:, discourse_site:, directory:, markdown:)
        @api_key = api_key
        @discourse_site = discourse_site
        @directory = directory
        @markdown = markdown
        @base_url = @discourse_site.base_url
        @internal_link_regex = /(?<!!)\[\[(.*?)\]\]/
      end

      def handle
        internal_links = []
        link_adjusted = @markdown.gsub(@internal_link_regex) do |link_match|
          title = link_match.match(@internal_link_regex)[1]
          internal_links << title
          linked_note = Note.find_by(title:, directory: @directory)
          topic_url = linked_note&.topic_url
          topic_url ||= if linked_note&.local_only
                          local_only_placeholder_topic(title, linked_note)
                        else
                          placeholder_topic(title)
                        end
          new_link = "[#{title}](#{topic_url})"
          new_link
        rescue StandardError => e
          raise Discourse::Errors::BaseError,
                "Error converting internal link to relative link: #{e.message}"
        end
        [link_adjusted, internal_links]
      end

      private

      def local_only_placeholder_topic(title, linked_note)
        markdown = "This is a placeholder topic for the local only note _#{title}_."
        post_data = create_discourse_topic(title, markdown)
        update_note_entry(post_data, linked_note)
      end

      def placeholder_topic(title)
        markdown = "This is a placeholder topic for _#{title}_."
        post_data = create_discourse_topic(title, markdown)
        note = create_note_entry(title, post_data)
        note.topic_url
      end

      def create_discourse_topic(title, markdown)
        client = DiscourseRequest.new(@discourse_site, @api_key)
        client.create_topic(title:, markdown:, tags: [@discourse_site.site_tag],
                            category: @directory.discourse_category.discourse_id).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to create linked topic for '#{title}'"
          end
        end
      end

      def create_note_entry(title, post_data)
        topic_url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        Note.create(title:, topic_url:, topic_id:, post_id:,
                    directory: @directory,
                    discourse_site: @discourse_site).tap do |note|
          raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
        end
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error creating Note: #{e.message}"
      end

      def update_note_entry(post_data, note)
        topic_url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        note.update(topic_url:, topic_id:, post_id:).tap do |updated_note|
          unless updated_note
            raise Discourse::Errors::BaseError, 'Note entry for linked note could not be updated'
          end
        end
        topic_url
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error updating linked Note entry: #{e.message}"
      end

      def url_from_post_data(post_data)
        "#{@base_url}/t/#{post_data['topic_slug']}/#{post_data['topic_id']}"
      end
    end
  end
end
