# frozen_string_literal: true

require_relative 'ui_utils'
require_relative 'update_tags_frame'

module Discourse
  module Utils
    class TagSelectorFrame
      class << self
        def call(directory:, api_key:)
          @directory = directory
          @api_key = api_key
          tag_selector_frame
        end

        private

        def tag_selector_frame
          short_path = Discourse::Utils::Ui.fancy_path(@directory.path)
          CLI::UI::Frame.open("Tags for {{blue:#{short_path}}}") do
            tags_for_directory(short_path)
          end
        end

        def tags_for_directory(short_path)
          if @directory.tags
            handle_configured_tags(short_path)
          else
            configure_tags(short_path)
          end
        end

        def handle_configured_tags(short_path)
          initial_tags = @directory.tags
          configuration_options = CLI::UI::Prompt
                                  .ask("{{blue:#{short_path}}} has been configured to tag " \
                                       'notes published to Discourse with  ' \
                                       "'#{comma_separated_tags(initial_tags)}'.",
                                       options: %w[keep change])

          return if configuration_options == 'keep'

          configure_tags(short_path)
          update_directory_topic_tags(initial_tags)
        end

        def configure_tags(short_path)
          add_tags = CLI::UI::Prompt
                     .confirm("Add tags to all topics published from {{blue:#{short_path}}}?")
          return unless add_tags

          tags = []
          loop do
            tag = CLI::UI::Prompt.ask('Enter a tag')
            confirm = CLI::UI::Prompt.confirm("Is '#{tag}' correct?")
            tags << tag if confirm

            progress = CLI::UI::Prompt.ask("Current tags: '#{tags.join(', ')}'. Add more tags?",
                                           options: ['yes', 'no', 'start over'])
            break if progress == 'no'

            tags = [] if progress == 'start over'
          end
          confirm_tags = CLI::UI::Prompt
                         .confirm("Selected tags: '#{tags.join(', ')}'. Is that correct?")

          return unless confirm_tags

          update_directory_tags(tags.join('|'))
        end

        def comma_separated_tags(tags_str)
          tags_str.split('|').join(', ')
        end

        def update_directory_tags(tags_str)
          @directory.update(tags: tags_str).tap do |response|
            unless response
              raise Discourse::Errors::BaseError,
                    "Unable to update directory for tags: #{tags_str}"
            end
          end
        rescue StandardError => e
          raise Discourse::Errors::BaseError, "Error updating tags: #{e.message}"
        end

        def update_directory_topic_tags(initial_tags)
          tag_updater = Discourse::Utils::UpdateTagsFrame
                        .new(discourse_site: @directory.discourse_site,
                             api_key: @api_key)
          tag_updater.update_directory_topics(directory: @directory, old_tags: initial_tags)
        end
      end
    end
  end
end
