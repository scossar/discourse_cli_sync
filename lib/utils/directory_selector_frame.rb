# frozen_string_literal: true

require_relative '../models/directory'
require_relative 'ui_utils'

module Discourse
  module Utils
    module DirectorySelectorFrame
      def self.select(site, confirm_subdirectories: true)
        select_directory(site, confirm_subdirectories)
      end

      def self.select_directory(site, confirm_subdirectories)
        directory = nil
        directories = Discourse::Directory.where(discourse_site: site)
        paths = directories.pluck(:path)
        fancy_paths = paths.map { |path| Discourse::Utils::Ui.fancy_path(path) }
        subdirectories = false
        selected_directory = nil
        CLI::UI::Frame.open("Select directory for #{site.domain}") do
          loop do
            directory = CLI::UI::Prompt.ask('Select directory', options: fancy_paths)
            confirm = CLI::UI::Prompt.confirm("Is #{directory} correct?")
            break if confirm
          end
          if confirm_subdirectories
            subdirectories = CLI::UI::Prompt.confirm("Also select subdirectories of #{directory}?")
          end
          selected_directory = Discourse::Directory.find_by(path: File.expand_path(directory))
        end
        [selected_directory, subdirectories]
      end
    end
  end
end
