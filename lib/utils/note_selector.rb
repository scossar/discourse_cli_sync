# frozen_string_literal: true

require_relative '../models/directory'
require_relative '../utils/ui_utils'

module Discourse
  module Utils
    class NoteSelector
      class << self
        def call(host)
          dir = select_dir
          select_notes(host, dir)
        end

        def directory_prompt
          'Note directory'
        end

        def directory_confirm_prompt(dir)
          "is #{dir} correct?"
        end

        def note_prompt(host)
          "Notes to publish to #{host}"
        end

        def note_confirm_prompt(notes)
          num_notes = notes.length
          colored_notes = notes.map { |note| "{{green:#{note}}}" }
          notes_str = colored_notes.join(', ')
          if num_notes == 1
            "Is #{notes_str} the note you want to publish?"
          else
            "Are #{notes_str} the notes you want to publish?"
          end
        end

        def select_dir
          dir = nil
          directories = Discourse::Directory.all.pluck(:path)
          fancy_paths = directories.map { |directory| Discourse::Utils::Ui.fancy_path(directory) }
          loop do
            dir = CLI::UI::Prompt.ask(directory_prompt, options: fancy_paths)
            confirm = CLI::UI::Prompt.confirm(directory_confirm_prompt(dir))
            return dir if confirm
          end
        end

        # TODO: handle the case of an empty selection
        def select_notes(host, dir)
          notes = nil
          loop do
            notes = CLI::UI::Prompt.ask(note_prompt(host), options: notes_for_dir(dir),
                                                           multiple: true)
            confirm = CLI::UI::Prompt.confirm(note_confirm_prompt(notes))
            break if confirm
          end
          [notes, dir]
        end

        def notes_for_dir(dir)
          expanded_dir = File.expand_path(dir)
          note_paths = Dir.glob(File.join(expanded_dir, '*.md'))
          note_paths.map { |path| File.basename(path) }
        end
      end
    end
  end
end
