# frozen_string_literal: true

require_relative '../models/note'
module Discourse
  module Utils
    class RecategorizeNotesFrame
      class << self
        def call(directory:, discourse_site:, api_key:)
          @directory = directory
          @discourse_site = discourse_site
          @api_key = api_key
          recategorize_notes
        end

        private

        def recategorize_notes
          notes = Discourse::Note.where(directory: @directory, discourse_site: @discourse_site)
          CLI::UI::Frame.open('Recategorize notes') do
            puts notes
          end
        end
      end
    end
  end
end
