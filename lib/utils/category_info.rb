# frozen_string_literal: true

require_relative '../services/discourse_category_fetcher'
require_relative '../models/discourse_category'

module Discourse
  module Utils
    module CategoryInfo
      def self.category_loader(host, api_key)
        fetcher = DiscourseCategoryFetcher.new(host, api_key)

        spin_group = CLI::UI::SpinGroup.new

        spin_group.failure_debrief do |_title, exception|
          puts CLI::UI.fmt "  #{exception}"
        end

        categories, category_names = nil
        spin_group.add('Categories') do |spinner|
          categories = fetcher.categories
          category_names = fetcher.category_names
          spinner.update_title('Categories loaded')
        end

        spin_group.wait

        category_info(categories)
        [categories, category_names]
      end

      def self.category_info(categories)
        categories.each_value do |category|
          CLI::UI::Frame.open(category[:name]) do
            create_or_update_category(category)
            puts CLI::UI.fmt "read_restricted: #{category[:read_restricted]}"
            puts CLI::UI.fmt category[:description_excerpt]
          end
        end
      end

      def self.create_or_update_category(category)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.failure_debrief do |_title, exception|
          puts CLI::UI.fmt "  #{exception}"
        end

        spin_group.add('Updating Categories') do |spinner|
          Discourse::DiscourseCategory
            .create_or_update(name: category[:name],
                              slug: category[:slug],
                              read_restricted: category[:read_restricted],
                              description: category[:description_excerpt])
          spinner.update_title("Updated info for #{category[:name]}")
        end

        spin_group.wait
      end
    end
  end
end
