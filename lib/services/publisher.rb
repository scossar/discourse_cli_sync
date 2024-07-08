# frozen_string_literal: true

require 'front_matter_parser'

require_relative 'attachment_handler'
require_relative '../errors/errors'
require_relative 'internal_link_handler'
require_relative 'discourse_request'

module Discourse
  module Services
    class Publisher
      def initialize(note_path:, directory:, api_key:, discourse_site:)
        @note_path = note_path
        @directory = directory
        @api_key = api_key
        @discourse_site = discourse_site
        @client = DiscourseRequest.new(discourse_site, api_key)
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
                                                        discourse_site: @discourse_site,
                                                        directory: @directory,
                                                        markdown:)
        internal_link_handler.handle
      end

      def create_topic(title, markdown, front_matter)
        @client.create_topic(title:, markdown:,
                             category: @directory.discourse_category.discourse_id,
                             tags: [@discourse_site.site_tag]).tap do |response|
          unless response
            raise Discourse::Errors::BaseError,
                  "Failed to create topic for #{title}"
          end
          post_id = create_note_entry(title, response)
          update_front_matter(post_id, front_matter, markdown)
        end
      end

      def update_front_matter(post_id, front_matter, markdown)
        site_id_property = "#{@discourse_site.domain}_id: #{post_id}"
        properties = ''
        front_matter.each do |key, value|
          properties += "\n#{key}: #{value}"
        end
        properties = "---\n#{site_id_property}#{properties}\n---\n"

        updated_file = "#{properties}\n#{markdown}"

        File.write(@note_path, updated_file)
      end

      def create_note_entry(title, post_data)
        topic_url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        Note.create(title:, topic_url:, topic_id:, post_id:, directory: @directory,
                    discourse_site: @discourse_site).tap do |note|
          raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
        end
        post_id
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error creating Note: #{e.message}"
      end

      def url_from_post_data(post_data)
        "#{@base_url}/t/#{post_data['topic_slug']}/#{post_data['topic_id']}"
      end

      def update_post(note, markdown)
        @client.update_post(markdown:, post_id: note.post_id).tap do |response|
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
