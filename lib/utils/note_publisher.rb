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
          @discourse_site = discourse_site
          @publisher = Discourse::Services::Publisher.new(note_path:, directory:, api_key:,
                                                          discourse_site: @discourse_site)
          @title, _front_matter, @markdown = @publisher.parse_file
          @directory = directory
          @note = Discourse::Note.find_by(title: @title, directory: @directory)
          publishing_frame(require_confirmation)
        end

        private

        def publishing_frame(require_confirmation)
          spin_group = CLI::UI::SpinGroup.new

          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end
          if require_confirmation
            publish_with_confirmation(spin_group)
          else
            publish(spin_group)
          end
        end

        def publish_with_confirmation(spin_group)
          local_status = confirm_local_status(spin_group)
          return unless local_status == :not_local

          publish_status = confirm_publish_status(spin_group)
          return unless publish_status == :publish

          attachments_task(spin_group)
          internal_links_task(spin_group)
          publish_task(spin_group)
        end

        def publish(spin_group)
          skip = local_only_task(spin_group)
          return if skip

          attachments_task(spin_group)
          internal_links_task(spin_group)
          publish_task(spin_group)
        end

        def confirm_local_status(spin_group)
          if @note&.local_only
            keep_local_status = CLI::UI::Prompt
                                .confirm("#{@title} is set to local only. Keep that status?")
            return :local_only if keep_local_status

            return local_only_spinner(spin_group, false)
          else
            local_only = CLI::UI::Prompt.confirm("Set #{@title} to local only?")
            return local_only_spinner(spin_group, true) if local_only
          end
          :not_local
        end

        def local_only_spinner(spin_group, local_only)
          spinner_title = if local_only
                            "Configuring #{@title} to be a local only note"
                          else
                            "Configuring #{@title} to be published to Discourse"
                          end

          spin_group.add(spinner_title) do
            configure_local_status(local_only)
            sleep 0.25
          end
          spin_group.wait
          local_only ? :local_only : :not_local
        end

        def configure_local_status(local_only)
          if @note
            unless @note.update(local_only:)
              raise Discourse::Errors::BaseError, 'Note could not be updated'
            end
          else
            note = Discourse::Note.create(title: @title, directory: @directory, local_only:,
                                          discourse_category: @directory.discourse_category,
                                          discourse_site: @discourse_site)
            raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
          end
        rescue StandardError => e
          raise Discourse::Errors::BaseError,
                "Error creating or updating Note record: #{e.message}"
        end

        def confirm_publish_status(spin_group)
          publish_status = CLI::UI::Prompt.ask("Publish #{@title}?",
                                               options: ['publish', 'skip', 'show excerpt'])
          if publish_status == 'show excerpt'
            excerpt = @markdown.split[0, 50].join(' ')
            puts CLI::UI.fmt "Note excerpt:\n#{excerpt}..."
            publish_status = CLI::UI::Prompt.ask("Publish #{@title}?", options: %w[publish skip])
          end
          unless publish_status == 'publish'
            spin_group.add("Skipping publishing for #{@title}") do
              sleep 0.25
            end
            spin_group.wait
          end
          publish_status == 'publish' ? :publish : :skip
        end

        def local_only_task(spin_group)
          local_only = @note&.local_only
          return false unless local_only

          spin_group.add("Skipping publishing local only note #{@title}") do
            sleep 0.25
          end
          spin_group.wait
          true
        end

        def attachments_task(spin_group)
          spin_group.add("Handling uploads for #{@title}") do |spinner|
            @markdown, filenames = @publisher.handle_attachments(@markdown)
            spinner_title = uploads_title(filenames)
            spinner.update_title(spinner_title)
          end
          spin_group.wait
          @markdown
        end

        def internal_links_task(spin_group)
          spin_group.add("Handling internal links for #{@title}") do |spinner|
            @markdown, stub_topics = @publisher.handle_internal_links(@markdown)
            spinner_title = links_title(stub_topics)
            spinner.update_title(spinner_title)
          end
          spin_group.wait
          @markdown
        end

        def publish_task(spin_group)
          if @note
            update_topic(spin_group)
          else
            create_topic(spin_group)
          end
        end

        def update_topic(spin_group)
          spin_group.add("Updating topic for #{@title}") do |spinner|
            @publisher.update_topic(@note, @markdown)
            spinner.update_title("Topic updated for #{@title}")
          end
          spin_group.wait
        end

        def create_topic(spin_group)
          spin_group.add("Creating new topic for #{@title}") do |spinner|
            @publisher.create_topic(@title, @markdown)
            spinner.update_title("Topic created for #{@title}")
          end
          spin_group.wait
        end

        def uploads_title(filenames)
          if filenames.any?
            uploads_str = Discourse::Utils::Ui.colored_text_from_array(filenames, 'green')
            "Uploaded #{uploads_str} for {{green:#{@title}}}"
          else
            "No uploads for {{green:#{@title}}}"
          end
        end

        def links_title(stub_topics)
          if stub_topics.any?
            topics_str = Discourse::Utils::Ui.colored_text_from_array(stub_topics, 'green')
            "Generated stub topics for #{topics_str}"
          else
            "No internal links in {{green:#{@title}}}"
          end
        end
      end
    end
  end
end
