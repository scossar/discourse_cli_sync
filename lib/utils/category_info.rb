# frozen_string_literal: true

require_relative '../services/discourse_category_fetcher'
require_relative '../models/discourse_category'

module Discourse
  module Utils
    class CategoryInfo
      class << self
        def call(discourse_site:, api_key:)
          @discourse_site = discourse_site
          @api_key = api_key
          @fetcher = DiscourseCategoryFetcher.new(@discourse_site, @api_key)

          spin_group = CLI::UI::SpinGroup.new

          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          discourse_categories, discourse_category_names = nil
          spin_group.add('Categories') do |spinner|
            discourse_categories = @fetcher.categories
            discourse_category_names = @fetcher.category_names
            spinner.update_title('Categories loaded')
          end

          spin_group.wait

          check_for_missing(discourse_categories)
          category_info(discourse_categories)
          [discourse_categories, discourse_category_names]
        end

        private

        def check_for_missing(_discourse_categories)
          local_categories = Discourse::DiscourseCategory.where(discourse_site: @discourse_site)
          local_categories.each do |local|
            CLI::UI::Frame.open("Checking #{local.name}") do
              unless @fetcher.category_by_id(local.discourse_id)
                puts "missing discourse category for #{local.name}"
              end
            end
          end
        end

        def category_info(categories)
          categories.each_value do |category|
            CLI::UI::Frame.open("{{blue:#{category[:name]}}}") do
              create_or_update_category(category)
              puts CLI::UI.fmt "  {{cyan:read_restricted}}: #{category[:read_restricted]}"
              description = category[:description_excerpt] || 'No description available.'
              puts CLI::UI.fmt "  {{cyan:description}}: #{description}"
            end
          end
        end

        def create_or_update_category(category)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          spin_group.add('Updating local category data') do |spinner|
            Discourse::DiscourseCategory
              .create_or_update(name: category[:name],
                                slug: category[:slug],
                                read_restricted: category[:read_restricted],
                                description: category[:description_excerpt],
                                discourse_id: category[:id],
                                discourse_site: @discourse_site)
            spinner.update_title("Updated database entry for {{blue:#{category[:name]}}}")
          end

          spin_group.wait
        end
      end
    end
  end
end
