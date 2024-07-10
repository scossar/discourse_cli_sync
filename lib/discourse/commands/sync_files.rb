# frozen_string_literal: true

require 'front_matter_parser'

require_relative '../../utils/credential_frame'
require_relative '../../utils/configure_site'
require_relative '../../utils/vault_info'
require_relative '../../models/directory'
require_relative '../../models/note'

module Discourse
  module Commands
    class SyncFiles < Discourse::Command
      def call(_args, _name)
        @discourse_site = Discourse::Utils::ConfigureSite.call
        Discourse::Utils::VaultInfo.call(@discourse_site)

        list_files
      end

      def list_files
        CLI::UI::Frame.open('listing all files') do
          puts "listing all files for #{@discourse_site.vault_directory}"
          directory_files.each do |file|
            path = File.dirname(file)
            path = File.join(path, '/')
            discourse_directory = Discourse::Directory.find_by(path:,
                                                               discourse_site: @discourse_site)

            puts file
            ensure_front_matter(file)
          end
        end
      end

      def ensure_front_matter(file)
        front_matter, _markdown = parse_file(file)
        puts front_matter
      end

      def directory_files
        files = all_directories.map do |dir|
          Dir.glob(File.join(dir, '*.md'))
        end
        files.flatten
      end

      def all_directories
        root_dir = File.expand_path(@discourse_site.vault_directory)
        dirs = Dir.glob(File.join(root_dir, '**', '*/'))
        dirs << root_dir
      end

      def parse_file(file)
        content = File.read(file)
        parsed = FrontMatterParser::Parser.new(:md).call(content)
        [parsed.front_matter, parsed.content]
      end

      def next_file_id
        last_id = Discourse::Note.all.pluck(:id).max
        last_id ? last_id + 1 : 0
      end

      def self.help
        'Syncs vault files with the database'
      end
    end
  end
end
