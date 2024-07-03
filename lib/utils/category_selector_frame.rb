# frozen_string_literal: true

require_relative '../models/discourse_category'
require_relative '../models/directory'
require_relative 'ui_utils'

module Discourse
  module Utils
    class CategorySelectorFrame
      class << self
        def call(directory:, use_subdirectories:, api_key:, discourse_site:)
          @directory = directory
          @discourse_site = discourse_site
          @api_key = api_key
          selector_frame(use_subdirectories)
        end

        private

        def selector_frame(use_subdirectories)
          path = @directory.path
          directories = use_subdirectories ? sub_directories(path) : [@directory]
          CLI::UI::Frame.open(category_frame_title(path, directories.length)) do
            directories.each do |dir|
              category_for_directory(dir)
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

        def handle_configured_category(dir:, configured_category:)
          short_path = Discourse::Utils::Ui.fancy_path(dir.path)
          reconfigure = CLI::UI::Prompt
                        .confirm("#{short_path} has been configured to publish notes " \
                                 "to #{configured_category.name}. Would you like to " \
                                 'reconfigure it?')

          return unless reconfigure

          confirm = CLI::UI::Prompt
                    .confirm("Confirm that you want to change the category for #{short_path}")
          return unless confirm

          configure_category(dir)
        end

        def configure_category(dir)
          category_name = nil
          short_path = Discourse::Utils::Ui.fancy_path(dir.path)
          loop do
            category_name = CLI::UI::Prompt.ask("Category for #{short_path}",
                                                options: discourse_category_names)
            confirm = CLI::UI::Prompt.confirm("Is #{category_name} correct?")
            break if confirm
          end

          category = Discourse::DiscourseCategory.find_by(name: category_name,
                                                          discourse_site: @discourse_site)
          dir.update(discourse_category: category)
        end

        def sub_directories(path)
          Discourse::Directory.where('path LIKE ?',
                                     "#{path}%").where(discourse_site: @discourse_site)
        end

        def category_frame_title(path, count)
          fancy_path = Discourse::Utils::Ui.fancy_path(path)
          if count == 1
            "Configure category for #{fancy_path}"
          else
            "Configure categories for #{fancy_path}"
          end
        end

        def discourse_category_names
          Discourse::DiscourseCategory.all.pluck(:name)
        end
      end
    end
  end
end
