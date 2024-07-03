# frozen_string_literal: true

require_relative 'ui_utils'

module Discourse
  module Utils
    module PublishDirectoryFrame
      def self.publish_directories(root_directory:, directories:)
        publish_frame(root_directory, directories)
      end

      def self.publish_frame(root_directory, directories)
        directories.each do |directory|
          short_path = short_path(root_directory)
          CLI::UI::Frame.open("Publishing notes from #{short_path}") do
            publish_directory(directory)
          end
        end
      end

      def self.publish_directory(directory)
        spin_group = CLI::UI::SpinGroup.new

        spin_group.failure_debrief do |_title, exception|
          puts CLI::UI.fmt "  #{exception}"
        end

        _paths, titles, titles_path_hash = notes_for_directory(directory)

        titles.each do |title|
          spin_group.add("Publishing #{title}") do |spinner|
            sleep 1.0
            spinner.update_title "Published (full path) #{path_from_title(titles_path_hash,
                                                                          title)}"
          end
          spin_group.wait
        end
      end

      def self.notes_for_directory(directory)
        paths = Dir.glob(File.join(directory.path, '*.md'))
        titles = paths.map { |path| File.basename(path) }
        titles_path_hash = titles_path_hash(titles, paths)
        [paths, titles, titles_path_hash]
      end

      def self.titles_path_hash(titles, paths)
        titles.zip(paths).to_h
      end

      def self.path_from_title(title_path_mapping, title)
        title_path_mapping[title]
      end

      def self.short_path(directory)
        Discourse::Utils::Ui.fancy_path(directory.path)
      end
    end
  end
end
