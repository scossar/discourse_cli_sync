# frozen_string_literal: true

require_relative 'note_publisher'
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
          paths, _titles, _titles_path_hash = notes_for_directory(directory)

          paths.each do |note_path|
            Discourse::Utils::NotePublisher.call(note_path:,
                                                 directory:,
                                                 api_key: @api_key,
                                                 discourse_site: @discourse_site)
          end
        end

        # TODO: not being used
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
