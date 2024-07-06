# frozen_string_literal: true

require_relative '../services/discourse_category_fetcher'
require_relative '../models/discourse_category'
require_relative '../models/directory'
require_relative '../errors/errors'
require_relative 'recategorize_notes_frame'

module Discourse
  module Utils
    class CategoryInfo
      class << self
        def call(discourse_site:, api_key:)
          @discourse_site = discourse_site
          @api_key = api_key
          @fetcher = DiscourseCategoryFetcher.new(@discourse_site, @api_key)

          category_info
          check_for_missing
        end

        private

        def category_info
          @fetcher.categories.each_value do |category|
            CLI::UI::Frame.open("{{blue:#{category[:name]}}}") do
              create_or_update_category(category)
              puts CLI::UI.fmt "  {{cyan:read_restricted}}: #{category[:read_restricted]}"
              description = category[:description_excerpt] || 'No description available.'
              puts CLI::UI.fmt "  {{cyan:description}}: #{description}"
            end
          end
        end

        def check_for_missing
          local_categories = Discourse::DiscourseCategory.where(discourse_site: @discourse_site)
          local_categories.each do |local_category|
            CLI::UI::Frame.open("Checking #{local_category.name}") do
              if @fetcher.category_by_id(local_category.discourse_id)
                puts 'category found'
              else
                handle_missing_category(local_category, local_categories)
              end
            end
          end
        end

        def handle_missing_category(local_category, local_categories)
          vault_directories = Discourse::Directory.where(discourse_category: local_category,
                                                         discourse_site: @discourse_site)
          return handle_delete_category(local_category) unless vault_directories.any?

          options = local_categories.pluck(:name)
          options -= [local_category.name]

          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          vault_directories.each do |directory|
            selected_name = nil
            loop do
              prompt = "The category associated with #{directory.path} has been deleted " \
                       "on #{@discourse_site.domain}. Select a new category for the directory"
              selected_name = CLI::UI::Prompt.ask(prompt, options:)
              confirm = CLI::UI::Prompt.confirm("Is #{selected_name} correct?")
              break if confirm
            end

            update_directory_category(spin_group:, directory:, categories: local_categories,
                                      category_name: selected_name)
          end
        end

        def update_directory_category(spin_group:, directory:, categories:, category_name:)
          spin_group.add("Updating category for #{directory.path}") do |spinner|
            discourse_category = categories.find do |category|
              category.name == category_name
            end
            directory.update(discourse_category:).tap do |dir|
              raise Discourse::Errors::BaseError unless dir
            end
            spinner.update_title("Updated category for #{directory.path} to #{discourse_category.name}")
          end
          spin_group.wait

          Discourse::Utils::RecategorizeNotesFrame.call(directory:,
                                                        discourse_site: @discourse_site, api_key: @api_key)
        end

        def handle_delete_category(discourse_category)
          CLI::UI::Frame.open('delete category') do
            "The category #{discourse_category.name} needs to be deleted"
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
