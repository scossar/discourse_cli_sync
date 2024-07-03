# frozen_string_literal: true

require_relative '../models/directory'
require_relative 'ui_utils'
require_relative 'logger'

module Discourse
  module Utils
    module DirectorySelectorFrame
      def self.select(site, confirm_subdirectories: true)
        select_directory(site, confirm_subdirectories)
      end

      def self.select_directory(site, confirm_subdirectories)
        directories = Discourse::Directory.where(discourse_site: site)
        paths = directories.pluck(:path)
        short_paths = short_paths(paths)
        path_mapping = short_paths_hash(short_paths, paths)

        subdirectories = false
        directory = nil
        CLI::UI::Frame.open("Select directory for #{site.domain}") do
          loop do
            directory = CLI::UI::Prompt.ask('Select directory', options: short_paths)
            confirm = CLI::UI::Prompt.confirm("Is #{directory} correct?")
            break if confirm
          end
          # TODO: don't ask about subdirectories if there are no subdirectories
          if confirm_subdirectories
            subdirectories = CLI::UI::Prompt.confirm("Also select subdirectories of #{directory}?")
          end
        end
        selected_directory = directory_from_short_path(directories:, path_mapping:,
                                                       short_path: directory)
        [selected_directory, subdirectories]
      end

      def self.directory_from_short_path(directories:, path_mapping:, short_path:)
        actual_path = path_mapping[short_path]
        directories.find { |dir| dir.path == actual_path }
      end

      def self.short_paths_hash(short_paths, paths)
        short_paths.zip(paths).to_h
      end

      def self.short_paths(paths)
        paths.map { |path| Discourse::Utils::Ui.fancy_path(path) }
      end
    end
  end
end
