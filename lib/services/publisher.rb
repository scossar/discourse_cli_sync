# frozen_string_literal: true

require 'front_matter_parser'

require_relative 'attachment_handler'
require_relative '../errors/errors'
require_relative 'internal_link_handler'
require_relative 'discourse_request'

module Discourse
  module Services
    class Publisher
      def initialize(host:, api_key:, note:, category:)
        @host = host
        @api_key = api_key
        @note = note
        @category = category
        @client = DiscourseRequest.new(@host, @api_key)
      end

      def parse_file
        title = File.basename(@note, '.md')
        content = File.read(@note)
        parsed = FrontMatterParser::Parser.new(:md).call(content)
        front_matter = parsed.front_matter
        markdown = parsed.content
        [title, front_matter, markdown]
      end

      def handle_attachments(markdown)
        attachment_handler = AttachmentHandler.new(host: @host, api_key: @api_key, markdown:)
        attachment_handler.convert
      end

      def handle_internal_links(markdown)
        internal_link_handler = InternalLinkHandler.new(host: @host, api_key: @api_key, markdown:,
                                                        category: @category)
        internal_link_handler.handle
      end

      def create_topic(title, markdown)
        @client.create_topic(title:, markdown:, category: @category.discourse_id).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to create topic for #{title}"
          end
          create_note_entry(title, response)
        end
      end

      def create_note_entry(title, post_data)
        topic_url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        Note.create(title:, topic_url:, topic_id:, post_id:,
                    discourse_category: @category).tap do |note|
          raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
        end
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error creating Note: #{e.message}"
      end

      def url_from_post_data(post_data)
        "#{@base_url}/t/#{post_data['topic_slug']}/#{post_data['topic_id']}"
      end

      def update_topic(note, markdown)
        @client.update_post(markdown:, post_id: note.post_id).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to update topic for #{note.title}"
          end
        end
      end
    end
  end
end
