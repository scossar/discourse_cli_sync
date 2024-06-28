# frozen_string_literal: true

module Discourse
  module Services
    class NoteSelector
      class << self
        def call(host)
          select_note(host)
        end

        def note_prompt(host)
          "Note to publish to #{host}"
        end

        def note_confirm_prompt(note)
          "Is #{note} correct?"
        end

        def select_note(host)
          note = nil
          loop do
            note = CLI::UI::Prompt.ask(note_prompt(host), is_file: true)
            confirm = CLI::UI::Prompt.confirm(note_confirm_prompt(note))
            break if confirm
          end
          note
        end
      end
    end
  end
end
