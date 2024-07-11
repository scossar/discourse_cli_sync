# frozen_string_literal: true

require_relative '../models/discourse_category'
require_relative '../models/directory'
require_relative 'category_selector_frame'
require_relative 'tag_selector_frame'

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
          directories.each do |directory|
            Discourse::Utils::CategorySelectorFrame.call(directory:, categories: @categories,
                                                         api_key: @api_key)
            Discourse::Utils::TagSelectorFrame.call(directory:, api_key: @api_key)
          end
          directories
        end

        def sub_directories(path)
          # This works, but...
          Discourse::Directory.where('path LIKE ?',
                                     "#{path}%").where(discourse_site: @discourse_site)
        end
      end
    end
  end
end
