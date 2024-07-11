# frozen_string_literal: true

require_relative 'ui_utils'
require_relative '../models/discourse_category'
require_relative 'recategorize_notes_frame'

module Discourse
  module Utils
    class CategorySelectorFrame
      class << self
        def call(directory:, categories:, api_key:)
          @directory = directory
          @discourse_site = @directory.discourse_site
          @categories = categories
          @api_key = api_key
          category_selector_frame
        end

        private

        def category_selector_frame
          short_path = Discourse::Utils::Ui.fancy_path(@directory.path)
          CLI::UI::Frame.open("Category for {{blue:#{short_path}}}") do
            category_for_directory(short_path)
          end
        end

        def category_for_directory(short_path)
          if @directory.discourse_category
            handle_configured_category(short_path)
          else
            configure_category(short_path)
          end
        end

        def handle_configured_category(short_path)
          configured_category = @directory.discourse_category.name
          keep_configuration = CLI::UI::Prompt
                               .confirm("{{blue:#{short_path}}} has been configured to publish " \
                                        "notes to #{configured_category}. Keep this configuration?")
          return if keep_configuration

          confirm = CLI::UI::Prompt
                    .confirm('Confirm that you want to change the category for  ' \
                             "#{configured_category}?")
          return unless confirm

          configure_category(short_path)

          # TODO: The args for RecategorizeNotexFrame could be simplified
          Discourse::Utils::RecategorizeNotesFrame.call(directory: @directory,
                                                        discourse_site: dir.discourse_site,
                                                        api_key: @api_key)
        end

        def configure_category(short_path)
          category_name = nil
          loop do
            category_name = CLI::UI::Prompt.ask("Category for {{blue:#{short_path}}}",
                                                options: category_names)
            confirm = CLI::UI::Prompt.confirm("Is #{category_name} correct?")
            break if confirm
          end

          category = Discourse::DiscourseCategory.find_by(name: category_name,
                                                          discourse_site: @discourse_site)
          @directory.update(discourse_category: category)
        end

        def category_names
          @categories.pluck(:name)
        end
      end
    end
  end
end
