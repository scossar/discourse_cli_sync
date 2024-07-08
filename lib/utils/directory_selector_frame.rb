# frozen_string_literal: true

require_relative '../models/directory'
require_relative 'ui_utils'
require_relative 'logger'

module Discourse
  module Utils
    class DirectorySelectorFrame
      class << self
        def call(discourse_site:, confirm_subdirectories: true)
          @discourse_site = discourse_site
          select_directory(confirm_subdirectories)
        end

        private

        def select_directory(confirm_subdirectories)
          directories = Discourse::Directory.where(discourse_site: @discourse_site)
          paths = directories.pluck(:path)
          short_paths = short_paths(paths)
          path_mapping = short_paths_hash(short_paths, paths)

          include_subdirectories = false
          directory = nil
          CLI::UI::Frame.open("Select directory for {{blue:#{@discourse_site.domain}}}") do
            loop do
              directory = CLI::UI::Prompt.ask('Select directory', options: short_paths)
              confirm = CLI::UI::Prompt.confirm("Is #{directory} correct?")
              break if confirm
            end
            if confirm_subdirectories && subdirectories?(path: directory)
              include_subdirectories = CLI::UI::Prompt
                                       .confirm("Also select subdirectories of #{directory}?")
            end
          end
          selected_directory = directory_from_short_path(directories:, path_mapping:,
                                                         short_path: directory)
          [selected_directory, include_subdirectories]
        end

        def directory_from_short_path(directories:, path_mapping:, short_path:)
          actual_path = path_mapping[short_path]
          directories.find { |dir| dir.path == actual_path }
        end

        def short_paths_hash(short_paths, paths)
          short_paths.zip(paths).to_h
        end

        def short_paths(paths)
          paths.map { |path| Discourse::Utils::Ui.fancy_path(path) }
        end

        def subdirectories?(path:)
          expanded_dir = File.expand_path(path)
          subdirs = Dir.glob(File.join(expanded_dir, '**', '*/'))
          subdirs.any?
        end
      end
    end
  end
end
