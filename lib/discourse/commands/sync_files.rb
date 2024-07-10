# frozen_string_literal: true

require 'fileutils'
require 'front_matter_parser'
require 'securerandom'

require_relative '../../utils/credential_frame'
require_relative '../../utils/configure_site'
require_relative '../../utils/vault_info'
require_relative '../../models/note'

module Discourse
  module Commands
    class SyncFiles < Discourse::Command
      def call(_args, _name)
        @discourse_site = Discourse::Utils::ConfigureSite.call
        @vault_directory = @discourse_site.vault_directory
        @file_id_key = 'cli_uuid'
        Discourse::Utils::VaultInfo.call(@discourse_site)

        update_front_matter
      end

      def update_front_matter
        CLI::UI::Frame.open("Ensuring the cli_uuid exists for all files in #{@vault_directory}") do
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end
          directory_files.each do |file|
            spin_group.add("Checking cli_uuid for #{file}") do |spinner|
              ensure_front_matter(file)
              spinner.update_title("cli_uuid set for #{file}")
            end
            spin_group.wait
          end
        end
      end

      def ensure_front_matter(file)
        front_matter, markdown = parse_file(file)
        return if front_matter[@file_id_key]

        front_matter[@file_id_key] = SecureRandom.uuid

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
          CLI::UI.fmt '{{red:SOMETHING WENT WRONG!!!}}'
          File.delete(temp_file_path)
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

      def self.help
        'Syncs vault files with the database'
      end
    end
  end
end
