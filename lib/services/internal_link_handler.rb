# frozen_string_literal: true

require_relative 'discourse_request'
require_relative '../errors/errors'
require_relative '../models/note'
require_relative '../utils/logger'

module Discourse
  module Services
    class InternalLinkHandler
      def initialize(api_key:, note:, directory:, markdown:)
        @api_key = api_key
        @note = note
        @directory = directory
        @discourse_site = @directory.discourse_site
        @markdown = markdown
        @base_url = @discourse_site.base_url
        @internal_link_regex = /(?<!!)\[\[(.*?)\]\]/
      end

      def handle
        internal_links = []
        link_adjusted = @markdown.gsub(@internal_link_regex) do |link_match|
          link_text = link_match.match(@internal_link_regex)[1]
          linked_note = find_linked_note(link_text)
          break unless linked_note

          topic_url = linked_note_topic_url(linked_note)
          internal_links << linked_note.title
          new_link = "[#{linked_note.title}](#{topic_url})"
          new_link
        rescue StandardError => e
          raise Discourse::Errors::BaseError,
                "Error converting internal link to relative link: #{e.message}"
        end
        [link_adjusted, internal_links]
      end

      private

      def find_linked_note(link_text)
        relative_path, title = parse_link(link_text)
        if relative_path
          find_note_by_path(relative_path, title)
        else
          Discourse::Note.find_by(title:)
        end
      end

      def linked_note_topic_url(linked_note)
        linked_note_topic = Discourse::DiscourseTopic.find_by(note: linked_note)
        topic_url = linked_note_topic&.topic_url
        topic_url || placeholder_topic(linked_note)
      end

      def placeholder_topic(note)
        title = note.title
        markdown = "This is a placeholder topic for _#{title}_."
        post_data = create_discourse_topic(title, markdown)
        create_discourse_topic_entry(note, post_data)
      end

      def parse_link(link_text)
        components = link_text.split('|')
        title = components.pop
        relative_path = components.empty? ? nil : components.join
        [relative_path, title]
      end

      def find_note_by_path(relative_path, title)
        root_dir = File.expand_path(@discourse_site.vault_directory)
        full_path = File.join(root_dir, relative_path, "#{title}.md")
        Discourse::Note.find_by(full_path:)
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

      def create_discourse_topic_entry(note, post_data)
        topic_url = url_from_post_data(post_data)
        topic_id = post_data['topic_id']
        post_id = post_data['id']
        Discourse::DiscourseTopic.create(note:, topic_url:, topic_id:, post_id:,
                                         directory: @directory,
                                         discourse_category: @directory.discourse_category,
                                         discourse_site: @discourse_site).tap do |topic|
          unless topic.persisted?
            raise Discourse::Errors::BaseError,
                  'DiscourseTopic could not be created'
          end
        end
        topic_url
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error creating DiscourseTopic: #{e.message}"
      end

      def url_from_post_data(post_data)
        "#{@base_url}/t/#{post_data['topic_slug']}/#{post_data['topic_id']}"
      end
    end
  end
end
