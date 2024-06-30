# frozen_string_literal: true

require_relative 'discourse_request'
require_relative '../errors/errors'
require_relative '../models/note'

module Discourse
  module Services
    class InternalLinkHandler
      def initialize(host:, api_key:, markdown:, category:)
        @host = host
        @api_key = api_key
        @markdown = markdown
        @category = category
        @base_url = Discourse::Config.get(host, 'base_url')
        @internal_link_regex = /(?<!!)\[\[(.*?)\]\]/
      end

      def handle
        internal_links = []
        link_adjusted = @markdown.gsub(@internal_link_regex) do |link_match|
          title = link_match.match(@internal_link_regex)[1]
          internal_links << title
          topic_url = Note.find_by(title:)&.topic_url
          topic_url ||= placeholder_topic(title)
          new_link = "[#{title}](#{topic_url})"
          new_link
        rescue StandardError => e
          raise Discourse::Errors::BaseError,
                "Error converting interal link to relative link: #{e.message}"
        end
        [link_adjusted, internal_links]
      end

      private

      def placeholder_topic(title)
        markdown = "This is a placeholder topic for #{title}"
        post_data = create_discourse_topic(title, markdown)
        note = create_note(title, post_data)
        note.topic_url
      end

      def create_discourse_topic(title, markdown)
        client = DiscourseRequest.new(@host, @api_key)
        client.create_topic(title:, markdown:, category: @category.discourse_id).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to create linked topic for '#{title}'"
          end
        end
      end

      def create_note(title, post_data)
        topic_url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        Note.create(title:, topic_url:, topic_id:, post_id:).tap do |note|
          raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
        end
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error creating Note: #{e.message}"
      end

      def url_from_post_data(post_data)
        "#{@base_url}/t/#{post_data['topic_slug']}/#{post_data['topic_id']}"
      end
    end
  end
end
