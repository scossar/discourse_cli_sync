# frozen_string_literal: true

require_relative 'discourse_request'
require_relative '../errors/errors'

module Discourse
  module Services
    class AttachmentHandler
      def initialize(host:, api_key:, markdown:)
        @host = host
        @api_key = api_key
        @markdown = markdown
        @attachment_tag_regex = /!\[\[(.*?)\]\]/
        @uploads_dir = Discourse::Config.get(host, 'vault_directory')
      end

      def convert
        file_names = []
        file_adjusted = @markdown.gsub(@attachment_tag_regex) do |tag_match|
          file_name = tag_match.match(@attachment_tag_regex)[1]
          file_names << file_name
          file_path = "#{@uploads_dir}/#{file_name}"
          response = upload_image(file_path)
          short_url = response['short_url']
          original_filename = response['original_filename']
          new_tag = "![#{original_filename}](#{short_url})"
          new_tag
        rescue StandardError => e
          raise Discourse::Errors::BaseError,
                "Error processing upload for #{tag_match}: #{e.message}"
        end
        [file_adjusted, file_names]
      end

      private

      def upload_image(image_path)
        puts "Uploading file '#{image_path}'"
        expanded_path = File.expand_path(image_path)
        client = DiscourseRequest.new(host, api_key)
        client.upload_file(expanded_path)
      end
    end
  end
end
