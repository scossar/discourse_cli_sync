# frozen_string_literal: true

require_relative '../models/discourse_category'
require_relative '../models/directory'
require_relative 'recategorize_notes_frame'
require_relative 'ui_utils'
# TODO: remove unused imports and use category_selector_frame and tag_selector_frame
require_relative 'category_selector_frame'

module Discourse
  module Utils
    class TaxonomySelectorFrames
      class << self
        def call(directory:, use_subdirectories:, api_key:, discourse_site:)
          @directory = directory
          @discourse_site = discourse_site
          @api_key = api_key
          @categories = Discourse::DiscourseCategory.where(discourse_site: @discourse_site)
          selector_frame(use_subdirectories)
        end

        private

        def selector_frame(use_subdirectories)
          path = @directory.path
          directories = use_subdirectories ? sub_directories(path) : [@directory]
          CLI::UI::Frame.open(category_frame_title(path, directories.length)) do
            directories.each do |dir|
              category_for_directory(dir)
              tags_for_directory(dir)
            end
          end
          directories
        end

        def category_for_directory(dir)
          if dir.discourse_category
            handle_configured_category(dir:, configured_category: dir.discourse_category)
          else
            configure_category(dir)
          end
        end

        def tags_for_directory(dir)
          if dir.tags
            handle_configured_tags(dir)
          else
            configure_tags(dir)
          end
        end

        def handle_configured_category(dir:, configured_category:)
          short_path = Discourse::Utils::Ui.fancy_path(dir.path)
          keep_configuration = CLI::UI::Prompt
                               .confirm("{{blue:#{short_path}}} has been configured to publish " \
                                        "notes to #{configured_category.name}. " \
                                        'Keep that configuration?')

          return if keep_configuration

          confirm = CLI::UI::Prompt
                    .confirm('Confirm that you want to change the category for ' \
                             "{{blue:#{short_path}}}")
          return unless confirm

          configure_category(dir)

          Discourse::Utils::RecategorizeNotesFrame.call(directory: dir,
                                                        discourse_site: @discourse_site,
                                                        api_key: @api_key)
        end

        def configure_category(dir)
          category_name = nil
          short_path = Discourse::Utils::Ui.fancy_path(dir.path)
          loop do
            category_name = CLI::UI::Prompt.ask("Category for {{blue:#{short_path}}}",
                                                options: category_names)
            confirm = CLI::UI::Prompt.confirm("Is #{category_name} correct?")
            break if confirm
          end

          category = Discourse::DiscourseCategory.find_by(name: category_name,
                                                          discourse_site: @discourse_site)
          dir.update(discourse_category: category)
        end

        def sub_directories(path)
          # I guess this works, but...
          Discourse::Directory.where('path LIKE ?',
                                     "#{path}%").where(discourse_site: @discourse_site)
        end

        def category_frame_title(path, count)
          fancy_path = Discourse::Utils::Ui.fancy_path(path)
          if count == 1
            "Configure category for {{blue:#{fancy_path}}}"
          else
            "Configure categories for {{blue:#{fancy_path}}}"
          end
        end

        def category_names
          @categories.pluck(:name)
        end

        def configure_tags(dir)
          short_path = Discourse::Utils::Ui.fancy_path(dir.path)
          add_tags = CLI::UI::Prompt.confirm("Add tags to all topics published from {{blue:#{short_path}}}?")
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

          dir.update(tags: tags_str).tap do |response|
            unless response
              raise Discourse::Errors::BaseError,
                    "Unable to update directory for tags: #{tags_str}"
            end
          end
        rescue StandardError => e
          raise Discourse::Errors::BaseError, "Error updating tags: #{e.message}"
        end

        def handle_configured_tags(dir)
          short_path = Discourse::Utils::Ui.fancy_path(dir.path)
          tags = dir.tags
          configuration_options = CLI::UI::Prompt
                                  .ask("{{blue:#{short_path}}} has been configured to tag " \
                                       "notes published to Discourse with #{tags}.",
                                       options: %w[keep change])

          return if configuration_options == 'keep'

          configure_tags(dir)
        end
      end
    end
  end
end
