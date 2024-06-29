# frozen_string_literal: true

require 'front_matter_parser'

require_relative 'attachment_handler'

module Discourse
  module Services
    class Publisher
      def initialize(host:, api_key:, note:)
        @host = host
        @note = note
        @api_key = api_key
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
    end
  end
end
