# frozen_string_literal: true

require_relative 'discourse_request'
require_relative '../errors/errors'
require_relative '../models/note'

module Discourse
  module Services
    class InternalLinkHandler
      def initialize(host:, api_key:, markdown:, category_id:)
        @host = host
        @api_key = api_key
        @markdown = markdown
        @category_id = category_id
        @base_url = Discourse::Config.get(host, 'base_url')
        @internal_link_regex = /(?<!!)\[\[(.*?)\]\]/
      end

      def handle
        internal_links = []
        link_adjusted = @markdown.gsub(@internal_link_regex) do |link_match|
          title = link_match.match(@internal_link_regex)[1]
          internal_links << title
          # TODO: a note needs to have a topic
          discourse_url = Note.find_by(title:)&.topic_url
          discourse_url ||= placeholder_topic(title)
          new_link = "[#{title}](#{discourse_url})"
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
        note = create_note(title)
        create_discourse_topic_entry(post_data, note)
      end

      def create_discourse_topic(title, markdown)
        client = DiscourseRequest.new(@host, @api_key)
        client.create_topic(title:, markdown:, category: @category_id).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to create linked topic for '#{title}'"
          end
        end
      end

      def create_note(title)
        Note.create(title:, local_only: false).tap do |note|
          raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
        end
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error creating Note: #{e.message}"
      end

      def url_from_post_data(response)
        "#{@base_url}/t/#{response['topic_slug']}/#{response['topic_id']}"
      end

      # NOTE: you need to figure out what's going on with categories
      def create_discourse_topic_entry(post_data, note)
        url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        DiscourseTopic.create(url:, topic_id:,
                              post_id:, note:).tap do |topic|
          unless topic.persisted?
            raise Discourse::Errors::BaseError, 'DiscourseTopic could not be created'
          end
        end
        url
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error creating DiscourseTopic: #{e.message}"
      end
    end
  end
end
