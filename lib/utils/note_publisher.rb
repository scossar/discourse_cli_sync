# frozen_string_literal: true

require_relative '../errors/errors'
require_relative 'ui_utils'
require_relative '../services/publisher'
require_relative '../models/note'
require_relative 'logger'

module Discourse
  module Utils
    class NotePublisher
      class << self
        def call(note_path:, directory:, api_key:, discourse_site:, require_confirmation: false)
          @publisher = Discourse::Services::Publisher.new(note_path:, directory:, api_key:,
                                                          discourse_site:)
          title, _front_matter, markdown = @publisher.parse_file
          @directory = directory
          @note = Discourse::Note.find_by(title:, directory: @directory)
          publishing_frame(title:, markdown:, require_confirmation:)
        end

        private

        def publishing_frame(title:, markdown:, require_confirmation:)
          spin_group = CLI::UI::SpinGroup.new

          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end
          publish = require_confirmation ? confirm_publishing(title:, markdown:) : true
          return unless publish

          return if local_only?

          markdown = attachments_task(spin_group:, title:, markdown:)
          markdown = internal_links_task(spin_group:, title:, markdown:)
          publish_task(spin_group:, title:, markdown:)
        end

        def confirm_publishing(title:, markdown:)
          publishing_option = CLI::UI::Prompt.ask("Publish #{title}?",
                                                  options: ['yes', 'no', 'show excerpt',
                                                            'mark as local only'])

          if publishing_option == 'show excerpt'
            excerpt = markdown.split[0, 50].join(' ')
            CLI::UI::Frame.open(title) do
              puts CLI::UI.fmt "{{green:#{excerpt}...}}"
            end
            publishing_option = CLI::UI::Prompt.ask("Publish #{title}?",
                                                    options: ['yes', 'no', 'mark as local only'])
          end
          if publishing_option == 'mark as local only'
            mark_note_as_local_only(title)
            return

          end
          publishing_option == 'yes'
        end

        def mark_note_as_local_only(title)
          if @note
            unless @note.update(local_only: true)
              raise Discourse::Errors::BaseError, 'Note could not be updated'
            end
          else
            note = Discourse::Note.create(title:, directory: @directory, local_only: true)
            raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
          end
        rescue StandardError => e
          raise Discourse::Errors::BaseError,
                "Error creating or updating Note record: #{e.message}"
        end

        def local_only?
          @note&.local_only
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

        def internal_links_task(spin_group:, title:, markdown:)
          spin_group.add("Handling internal links for #{title}") do |spinner|
            markdown, stub_topics = @publisher.handle_internal_links(markdown)
            spinner_title = links_title(stub_topics, title)
            spinner.update_title(spinner_title)
          end
          spin_group.wait
          markdown
        end

        def publish_task(spin_group:, title:, markdown:)
          if @note
            update_topic(spin_group:, title:, markdown:, note: @note)
          else
            create_topic(spin_group:, title:, markdown:)
          end
        end

        def update_topic(spin_group:, title:, markdown:, note:)
          spin_group.add("Updating topic for #{title}") do |spinner|
            @publisher.update_topic(note, markdown)
            spinner.update_title("Topic updated for #{title}")
          end
          spin_group.wait
        end

        def create_topic(spin_group:, title:, markdown:)
          spin_group.add("Creating new topic for #{title}") do |spinner|
            @publisher.create_topic(title, markdown)
            spinner.update_title("Topic created for #{title}")
          end
          spin_group.wait
        end

        def uploads_title(filenames, title)
          if filenames.any?
            uploads_str = Discourse::Utils::Ui.colored_text_from_array(filenames, 'green')
            "Uploaded #{uploads_str} for {{green:#{title}}}"
          else
            "No uploads for {{green:#{title}}}"
          end
        end

        def links_title(stub_topics, title)
          if stub_topics.any?
            topics_str = Discourse::Utils::Ui.colored_text_from_array(stub_topics, 'green')
            "Generated stub topics for #{topics_str}"
          else
            "No internal links in {{green:#{title}}}"
          end
        end
      end
    end
  end
end
