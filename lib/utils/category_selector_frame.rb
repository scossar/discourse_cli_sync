# frozen_string_literal: true

require_relative '../models/discourse_category'
require_relative '../models/directory'
require_relative 'ui_utils'

module Discourse
  module Utils
    module CategorySelectorFrame
      def self.select(directory, use_subdirectories)
        selector_frame(directory, use_subdirectories)
      end

      def self.selector_frame(directory, use_subdirectories)
        path = directory.path
        directories = use_subdirectories ? sub_directories(path) : directory
        category_names = discourse_category_names
        CLI::UI::Frame.open(category_frame_title(path, directories.length)) do
          directories.each do |dir|
            category_for_directory(dir, category_names)
          end
        end
      end

      def self.category_for_directory(directory, category_names)
        category_name = nil
        fancy_path = Discourse::Utils::Ui.fancy_path(directory.path)
        loop do
          category_name = CLI::UI::Prompt.ask("Category for #{fancy_path}",
                                              options: category_names)
          confirm = CLI::UI::Prompt.confirm("Is #{category_name} correct?")
          break if confirm
        end

        category = Discourse::DiscourseCategory.find_by(name: category_name)
        directory.update(discourse_category: category)
      end

      def self.sub_directories(path)
        Discourse::Directory.where('path LIKE ?', "#{path}%")
      end

      def self.category_frame_title(path, count)
        fancy_path = Discourse::Utils::Ui.fancy_path(path)
        count == 1 ? "Select category for #{fancy_path}" : "Select categories for #{fancy_path}"
      end

      def self.discourse_category_names
        Discourse::DiscourseCategory.all.pluck(:name)
      end
    end
  end
end
