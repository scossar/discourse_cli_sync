# frozen_string_literal: true

require 'front_matter_parser'

require_relative 'attachment_handler'
require_relative '../errors/errors'
require_relative 'internal_link_handler'
require_relative 'discourse_request'
require_relative '../models/discourse_topic'

module Discourse
  module Services
    class Publisher
      def initialize(note:, api_key:)
        @note = note
        @note_path = @note.full_path
        @directory = @note.directory
        @api_key = api_key
        @discourse_site = @note.discourse_site
        @client = DiscourseRequest.new(@discourse_site, api_key)
      end

      def parse_file
        title = File.basename(@note_path, '.md')
        content = File.read(@note_path)
        parsed = FrontMatterParser::Parser.new(:md).call(content)
        front_matter = parsed.front_matter
        markdown = parsed.content
        [title, front_matter, markdown]
      end

      def handle_attachments(markdown)
        attachment_handler = AttachmentHandler.new(api_key: @api_key,
                                                   discourse_site: @discourse_site,
                                                   markdown:)
        attachment_handler.convert
      end

      def handle_internal_links(markdown)
        internal_link_handler = InternalLinkHandler.new(api_key: @api_key,
                                                        note: @note,
                                                        markdown:)
        internal_link_handler.handle
      end

      def create_topic(title, markdown)
        @client.create_topic(title:, markdown:,
                             category: @directory.discourse_category.discourse_id,
                             tags: [@discourse_site.site_tag]).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to create topic for #{title}"
          end
          create_discourse_topic_entry(response)
        end
      end

      def create_discourse_topic_entry(post_data)
        topic_url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        Discourse::DiscourseTopic.create(note: @note, topic_url:, topic_id:, post_id:,
                                         directory: @directory,
                                         discourse_category: @directory.discourse_category,
                                         discourse_site: @discourse_site).tap do |topic|
          unless topic.persisted?
            raise Discourse::Errors::BaseError,
                  'DiscourseTopic entry could not be created'
          end
        end
      rescue StandardError => e
        raise Discourse::Errors::BaseError,
              "Error creating DiscourseTopic for post_id #{post_id}: #{e.message}"
      end

      def url_from_post_data(post_data)
        "#{@base_url}/t/#{post_data['topic_slug']}/#{post_data['topic_id']}"
      end

      def update_post(note, markdown, discourse_topic)
        @client.update_post(markdown:, post_id: discourse_topic.post_id).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to update topic for #{note.title}"
          end
        end
      end

      def update_topic(topic_id, params)
        @client.update_topic(topic_id:, params:).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to update topic for topic_id: #{topic_id}"
          end
        end
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error updating topic: #{e.message}"
      end
    end
  end
end
