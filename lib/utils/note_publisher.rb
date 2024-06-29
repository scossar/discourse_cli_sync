# frozen_string_literal: true

require_relative 'ui_utils'
require_relative '../services/publisher'

module Discourse
  module Utils
    class NotePublisher
      class << self
        def call(host:, api_key:, note:)
          @publisher = Discourse::Services::Publisher.new(host:, api_key:, note:)
          title, _front_matter, markdown = @publisher.parse_file
          publishing_frame(title, markdown)
        end

        def publishing_frame(title, markdown)
          spin_group = CLI::UI::SpinGroup.new

          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          markdown = attachments_task(spin_group:, title:, markdown:)
        end

        def attachments_task(spin_group:, title:, markdown:)
          spin_group.add("Handling uploads for #{title}") do |spinner|
            markdown, filenames = @publisher.handle_attachments(markdown)
            spinner_title = uploads_title(filenames, title)
            spinner.update_title(spinner_title)
          end
          spin_group.wait
          markdown
        end

        def uploads_title(filenames, title)
          if filenames.any?
            uploads_str = Discourse::Utils::Ui.colored_text_from_array(filenames, 'green')
            "Uploaded #{uploads_str} for {{green:#{title}}}"
          else
            "No uploads for {{green:#{title}}}"
          end
        end
      end
    end
  end
end
