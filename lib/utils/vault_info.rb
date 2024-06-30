# frozen_string_literal: true

require_relative '../models/directory'

module Discourse
  module Utils
    module VaultInfo
      def self.directory_loader(host)
        directory_info(host)
      end

      def self.directory_info(host)
        vault_dir = Discourse::Config.get(host, 'vault_directory')
        directories = all_directories(vault_dir)
        directories.each do |directory|
          CLI::UI::Frame.open(directory) do
            find_or_create_directory(directory)
          end
        end
      end

      def self.find_or_create_directory(directory)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.failure_debrief do |_title, exception|
          puts CLI::UI.fmt "  #{exception}"
        end

        spin_group.add('Updating Directories') do |spinner|
          Discourse::Directory.find_or_create_by(path: directory)
          spinner.update_title("Updated database entry for #{directory}")
        end

        spin_group.wait
      end

      def self.all_directories(vault_dir)
        expanded_dir = File.expand_path(vault_dir)
        subdirs = Dir.glob(File.join(expanded_dir, '**', '*/'))
        subdirs.map { |subdir| subdir.gsub(/^#{Regexp.escape(Dir.home)}/, '~') }
        subdirs << vault_dir
      end
    end
  end
end
