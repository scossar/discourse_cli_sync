# frozen_string_literal: true

require_relative 'ui_utils'

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
          tags = @directory.tags
          configuration_options = CLI::UI::Prompt
                                  .ask("{{blue:#{short_path}}} has been configured to tag " \
                                       "notes published to Discourse with #{tags}.",
                                       options: %w[keep change])

          return if configuration_options == 'keep'

          configure_tags(short_path)
          # TODO: call method to update tags for existing topics
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

            progress = CLI::UI::Prompt.ask("Current tags: #{tags.join('|')}. Add more tags?",
                                           options: ['yes', 'no', 'start over'])
            break if progress == 'no'

            tags = [] if progress == 'start over'
          end
          tags_str = tags.join('|')
          confirm_tags = CLI::UI::Prompt
                         .confirm("Selected tags: #{tags_str}. Tag notes " \
                                  "published from {{blue:#{short_path}}} with #{tags_str}?")

          return unless confirm_tags

          directory_tags(tags_str)
        end

        def directory_tags(tags_str)
          @directory.update(tags: tags_str).tap do |response|
            unless response
              raise Discourse::Errors::BaseError,
                    "Unable to update directory for tags: #{tags_str}"
            end
          end
        rescue StandardError => e
          raise Discourse::Errors::BaseError, "Error updating tags: #{e.message}"
        end
      end
    end
  end
end
