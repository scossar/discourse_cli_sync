# frozen_string_literal: true

require_relative '../models/directory'
require_relative '../utils/ui_utils'

module Discourse
  module Utils
    module VaultInfo
      def self.directory_loader(site)
        directory_info(site)
      end

      def self.directory_info(site)
        directories = all_directories(site.vault_directory)
        directories.each do |directory|
          fancy_path = Discourse::Utils::Ui.fancy_path(directory)
          CLI::UI::Frame.open(fancy_path) do
            find_or_create_directory(discourse_site: site, path: directory)
          end
        end
      end

      def self.find_or_create_directory(discourse_site:, path:)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.failure_debrief do |_title, exception|
          puts CLI::UI.fmt "  #{exception}"
        end

        spin_group.add('Updating Directories') do |spinner|
          Discourse::Directory.find_or_create_by(discourse_site:, path:)
          short_path = Discourse::Utils::Ui.fancy_path(path)
          spinner.update_title("Updated database entry for #{short_path}")
        end

        spin_group.wait
      end

      def self.all_directories(vault_dir)
        expanded_dir = File.expand_path(vault_dir)
        subdirs = Dir.glob(File.join(expanded_dir, '**', '*/'))
        subdirs << expanded_dir
      end
    end
  end
end
