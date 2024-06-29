# frozen_string_literal: true

require 'front_matter_parser'

module Discourse
  module Services
    class Publisher
      def initialize(note, api_key)
        @note = note
        @api_key = api_key
      end

      def parse_file(note)
        title = File.basename(note, '.md')
        content = File.read(note)
        parsed = FrontMatterParser::Parser.new(:md).call(content)
        front_matter = parsed.front_matter
        markdown = parsed.content
        [title, front_matter, markdown]
      end
    end
  end
end
