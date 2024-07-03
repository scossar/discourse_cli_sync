# frozen_string_literal: true

require_relative 'ui_utils'

module Discourse
  module Utils
    class DirectoryPublisher
      class << self
        def call(root_directory:, directories:, api_key:, discourse_site:)
          @directories = directories
          @api_key = api_key
          @discourse_site = discourse_site
          publish_frame(root_directory)
        end

        def publish_frame(root_directory)
          @directories.each do |directory|
            short_path = short_path(root_directory)
            CLI::UI::Frame.open("Publishing notes from #{short_path}") do
              publish_directory(directory)
            end
          end
        end

        def publish_directory(directory)
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

        def notes_for_directory(directory)
          paths = Dir.glob(File.join(directory.path, '*.md'))
          titles = paths.map { |path| File.basename(path) }
          titles_path_hash = titles_path_hash(titles, paths)
          [paths, titles, titles_path_hash]
        end

        def titles_path_hash(titles, paths)
          titles.zip(paths).to_h
        end

        def path_from_title(title_path_mapping, title)
          title_path_mapping[title]
        end

        def short_path(directory)
          Discourse::Utils::Ui.fancy_path(directory.path)
        end
      end
    end
  end
end
