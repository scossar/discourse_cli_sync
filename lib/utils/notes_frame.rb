# frozen_string_literal: true

require 'front_matter_parser'

require_relative '../errors/errors'
require_relative '../models/note'
require_relative '../models/directory'

module Discourse
  module Utils
    class NotesFrame
      class << self
        def call(discourse_site:)
          @discourse_site = discourse_site
          @vault_directory = @discourse_site.vault_directory
          @note_uuid_key = 'cli_uuid'
          @directories = Discourse::Directory.where(discourse_site: @discourse_site)
          @directory_files = directory_files
          update_notes
        end

        private

        def update_notes
          CLI::UI::Frame.open("Updating note entries for #{@vault_directory}") do
            spin_group = CLI::UI::SpinGroup.new
            spin_group.failure_debrief do |title, exception|
              puts CLI::UI.fmt "  #{title}"
              puts CLI::UI.fmt "  {{red:#{exception}}}"
            end
            @directory_files.each do |file|
              notes_task(spin_group, file)
            end
          end
        end

        def notes_task(spin_group, file)
          front_matter, _markdown = parse_file(file)
          cli_uuid = front_matter[@note_uuid_key]
          title = File.basename(file, '.md')
          note = Discourse::Note.find_by(file_id: cli_uuid, discourse_site: @discourse_site)
          file_path = File.dirname(file)
          directory = @directories.find_by(path: file_path)
          group_title = spin_group_title(note, title)

          spin_group.add(group_title) do
            if note
              Discourse::Note.update_note(note, title:, directory:)
            else
              Discourse::Note.create_note(title:, file_id: cli_uuid, directory:,
                                          discourse_site: @discourse_site)
            end
          end
          spin_group.wait
        end

        def spin_group_title(note, title)
          if note
            "Updating entry for {{green:#{title}}}"
          else
            "Creating entry for {{green:#{title}}}"
          end
        end

        def directory_files
          dir_paths = @directories.pluck(:path)
          files = dir_paths.map do |path|
            Dir.glob(File.join(path, '*.md'))
          end
          files.flatten
        end

        def parse_file(file)
          loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
          parsed = FrontMatterParser::Parser.parse_file(file, loader:)
          [parsed.front_matter, parsed.content]
        end
      end
    end
  end
end
