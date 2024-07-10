# frozen_string_literal: true

require 'fileutils'
require 'front_matter_parser'
require 'securerandom'

require_relative '../errors/errors'
require_relative '../models/directory'
require_relative '../models/note'

module Discourse
  module Utils
    class CliUuid
      class << self
        def call(discourse_site:)
          @discourse_site = discourse_site
          @vault_directory = @discourse_site.vault_directory
          @note_uuid_key = 'cli_uuid'
          @directories = Discourse::Directory.where(discourse_site: @discourse_site)
          @directory_files = directory_files
          ensure_cli_uuid
          update_notes
        end

        private

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
            @directory_files.each do |file|
              file_name = File.basename(file)
              spin_group.add("Checking cli_uuid for #{file_name}") do |spinner|
                handle_front_matter(file)
                spinner.update_title("cli_uuid set for {{green:#{file_name}}}")
              end
              spin_group.wait
            end
          end
        end

        def update_notes
          CLI::UI::Frame.open("Updating note entries for #{@vault_directory}") do
            spin_group = CLI::UI::SpinGroup.new
            spin_group.failure_debrief do |title, exception|
              puts CLI::UI.fmt "  #{title}"
              puts CLI::UI.fmt "  {{red:#{exception}}}"
            end
            @directory_files.each do |file|
              file_name = File.basename(file)
              spin_group.add("Creating or updating entry for #{file_name}") do |spinner|
                front_matter, _markdown = parse_file(file)
                cli_uuid = front_matter[@note_uuid_key]
                title = File.basename(file, '.md')
                directory_path = File.dirname(file)
                directory = Discourse::Directory.find_by(path: directory_path,
                                                         discourse_site: @discourse_site)
                Discourse::Note.create_or_update(discourse_site: @discourse_site, directory:,
                                                 file_id: cli_uuid, title:)
                spinner.update_title("Note saved for #{file_name}")
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
          dir_paths = @directories.pluck(:path)
          files = dir_paths.map do |path|
            Dir.glob(File.join(path, '*.md'))
          end
          files.flatten
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
