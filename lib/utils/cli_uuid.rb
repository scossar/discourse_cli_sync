# frozen_string_literal: true

require 'fileutils'
require 'front_matter_parser'
require 'securerandom'

require_relative '../errors/errors'

module Discourse
  module Utils
    class CliUuid
      class << self
        def call(discourse_site:)
          @discourse_site = discourse_site
          @vault_directory = @discourse_site.vault_directory
          @note_uuid_key = 'cli_uuid'
          ensure_cli_uuid
        end

        def ensure_cli_uuid
          CLI::UI::Frame
            .open("Ensuring the cli_uuid exists for all files in {{blue:#{@vault_directory}}}") do
            confirm = CLI::UI::Prompt
                      .confirm('The following operation will make changes to ' \
                               "{{blue:#{@vault_directory}}}. Do you want to continue?")
            raise Discourse::Errors::BaseError, 'Exiting now' unless confirm

            spin_group = CLI::UI::SpinGroup.new
            spin_group.failure_debrief do |_title, exception|
              puts CLI::UI.fmt "  #{exception}"
            end
            directory_files.each do |file|
              file_name = File.basename(file)
              spin_group.add("Checking cli_uuid for #{file_name}") do |spinner|
                handle_front_matter(file)
                spinner.update_title("cli_uuid set for {{green:#{file_name}}}")
              end
              spin_group.wait
            end
          end
        end

        def handle_front_matter(file)
          front_matter, markdown = parse_file(file)
          return if front_matter[@note_uuid_key]

          front_matter[@note_uuid_key] = SecureRandom.uuid

          properties = ''
          front_matter.each do |key, value|
            properties += "#{key}: #{value}\n"
          end
          properties = "---\n#{properties}---\n"

          updated_content = "#{properties}\n#{markdown}"

          temp_file_path = "#{file}.tmp"
          File.write(temp_file_path, updated_content)

          if File.read(temp_file_path) == updated_content
            FileUtils.mv(temp_file_path, file)
          else
            File.delete(temp_file_path)
            raise Discourse::Errors::BaseError,
                  "Error handling front_matter for #{file}"
          end
        end

        def directory_files
          files = all_directories.map do |dir|
            Dir.glob(File.join(dir, '*.md'))
          end
          files.flatten
        end

        def all_directories
          root_dir = File.expand_path(@vault_directory)
          dirs = Dir.glob(File.join(root_dir, '**', '*/'))
          dirs << root_dir
        end

        def parse_file(file)
          loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
          parsed = FrontMatterParser::Parser.parse_file(file, loader:)
          [parsed.front_matter, parsed.content]
        end
      end
    end
  end
end
