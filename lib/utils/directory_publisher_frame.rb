# frozen_string_literal: true

require_relative 'note_publisher'
require_relative 'ui_utils'
require_relative '../models/note'

module Discourse
  module Utils
    class DirectoryPublisherFrame
      class << self
        def call(root_directory:, directories:, api_key:, discourse_site:)
          @directories = directories
          @api_key = api_key
          @discourse_site = discourse_site
          publish_frame(root_directory)
        end

        def publish_frame(root_directory)
          require_confirmation = confirm_before_publishing?
          @directories.each do |directory|
            short_path = short_path(root_directory)
            CLI::UI::Frame.open("Publishing notes from #{short_path}") do
              publish_directory(directory, require_confirmation)
            end
          end
        end

        def publish_directory(directory, require_confirmation)
          notes = notes_for_directory(directory)

          notes.each do |note|
            Discourse::Utils::NotePublisher.call(note:, api_key: @api_key, require_confirmation:)
          end
        end

        def confirm_before_publishing?
          CLI::UI::Prompt.confirm('Ask for confirmation before publishing each note?')
        end

        # This isn't great but...
        def notes_for_directory(directory)
          Discourse::Note.where('path LIKE ?', directory.path)
        end

        def short_path(directory)
          Discourse::Utils::Ui.fancy_path(directory.path)
        end
      end
    end
  end
end
