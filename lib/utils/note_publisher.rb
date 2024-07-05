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
          publish_status = confirm_local_status(spin_group)
          return unless publish_status == :publish

          attachments_task(spin_group)
          internal_links_task(spin_group)
          publish_task(spin_group)
        end

        def publish(spin_group)
          attachments_task(spin_group)
          internal_links_task(spin_group)
          publish_task(spin_group)
        end

        def confirm_local_status(spin_group)
          if @note&.local_only
            keep_local_status = CLI::UI::Prompt.confirm("#{@title} is set to local only. Keep that status?")
            return :local_only if keep_local_status

            spin_group.add("Configuring #{@title} to be published to Discourse") do
              configure_local_status(false)
              sleep 0.25
            end
            spin_group.wait
            :publish
          else
            publish = CLI::UI::Prompt.confirm("Allow #{@title} to be published to Discourse?")
            unless publish
              spin_group.add("Configuring #{@title} to be a local only note") do
                configure_local_status(true)
                sleep 0.25
              end
              spin_group.wait
              return :local_only
            end
          end
          :publish
        end

        def configure_local_status(local_only)
          if @note
            unless @note.update(local_only:)
              raise Discourse::Errors::BaseError, 'Note could not be updated'
            end
          else
            note = Discourse::Note.create(title: @title, directory: @directory, local_only:)
            raise Discourse::Errors::BaseError, 'Note could not be created' unless note.persisted?
          end
        rescue StandardError => e
          raise Discourse::Errors::BaseError,
                "Error creating or updating Note record: #{e.message}"
        end

        def publish_method_task(spin_group:, title:, publish_method:)
          spin_group_title = if publish_method == :skip
                               "Skipping #{title}"
                             else
                               "Skipping local only note #{title}"
                             end
          spin_group.add(spin_group_title) do
            sleep 0.25
          end
          spin_group.wait
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
