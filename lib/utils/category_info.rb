# frozen_string_literal: true

require_relative '../services/discourse_category_fetcher'
require_relative '../models/discourse_category'
require_relative '../models/directory'
require_relative '../errors/errors'
require_relative 'recategorize_notes_frame'
require_relative 'ui_utils'

module Discourse
  module Utils
    class CategoryInfo
      class << self
        def call(discourse_site:, api_key:)
          @discourse_site = discourse_site
          @api_key = api_key
          @fetcher = DiscourseCategoryFetcher.new(@discourse_site, @api_key)

          category_info
          check_for_deleted_categories
        end

        private

        def category_info
          @fetcher.categories.each_value do |category|
            CLI::UI::Frame.open("Syncing {{blue:#{category[:name]}}}") do
              create_or_update_category(category)
              puts CLI::UI.fmt "  {{cyan:read_restricted}}: #{category[:read_restricted]}"
              description = category[:description_excerpt] || 'No description available.'
              puts CLI::UI.fmt "  {{cyan:description}}: #{description}"
            end
          end
        end

        def check_for_deleted_categories
          local_categories = Discourse::DiscourseCategory.where(discourse_site: @discourse_site)
          local_categories.each do |local_category|
            next if @fetcher.category_by_id(local_category.discourse_id)

            CLI::UI::Frame
              .open("Not syncing {{blue:#{local_category.name}}}") do
              handle_deleted_category(deleted_category: local_category, local_categories:)
            end
          end
        end

        def handle_deleted_category(deleted_category:, local_categories:)
          directories = Discourse::Directory.where(discourse_category: deleted_category,
                                                   discourse_site: @discourse_site)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          unless directories.any?
            return handle_delete_category(spin_group:,
                                          deleted_category:)
          end

          categories_for_directories(spin_group:, local_categories:,
                                     deleted_category:, directories:)
        end

        def categories_for_directories(spin_group:, local_categories:, deleted_category:,
                                       directories:)
          options = local_categories.pluck(:name)
          options -= [deleted_category.name]

          directories.each do |directory|
            short_path = Discourse::Utils::Ui.fancy_path(directory.path)
            selected_name = nil
            loop do
              prompt = "The category {{blue:#{deleted_category.name}}} has been deleted on " \
                       "{{blue:#{@discourse_site.domain}}}. Select a new category for " \
                       "{{blue:#{short_path}}}"
              selected_name = CLI::UI::Prompt.ask(prompt, options:)
              confirm = CLI::UI::Prompt.confirm("Is #{selected_name} correct?")
              break if confirm
            end

            update_directory_category(spin_group:, directory:, categories: local_categories,
                                      category_name: selected_name)
          end
        end

        def update_directory_category(spin_group:, directory:, categories:, category_name:)
          discourse_category = categories.find do |category|
            category.name == category_name
          end
          spin_group.add("Updating category for #{directory.path}") do |spinner|
            directory.update(discourse_category:).tap do |dir|
              raise Discourse::Errors::BaseError, 'Failed to update directory category' unless dir
            end
            spinner
              .update_title("Updated category for #{directory.path} to #{discourse_category.name}")
          end
          spin_group.wait

          Discourse::Utils::RecategorizeNotesFrame.call(directory:, api_key: @api_key)

          handle_delete_category(spin_group:, deleted_category: discourse_category)
        end

        def handle_delete_category(spin_group:, deleted_category:)
          spin_group.add("Deleting local entry for #{deleted_category.name}") do |spinner|
            Discourse::DiscourseCategory.find(deleted_category.id).destroy.tap do |result|
              unless result
                raise Discourse::Errors::BaseError,
                      "Failed to destroy #{deleted_category.name}"
              end
            end
            spinner.update_title("{{blue:#{deleted_category.name}}} has been deleted on " \
                                 "{{blue:#{@discourse_site.doman}}}. " \
                                 'Entry removed from local database.')
          end
          spin_group.wait
        end

        def create_or_update_category(category)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          spin_group.add('Updating local category data') do |spinner|
            Discourse::DiscourseCategory
              .create_or_update(name: category[:name],
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
