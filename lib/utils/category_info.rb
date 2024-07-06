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
              .open("{{blue:#{local_category.name}}} no longer exists on Discourse") do
              handle_deleted_category(local_category:, local_categories:)
            end
          end
        end

        def handle_deleted_category(local_category:, local_categories:)
          vault_directories = Discourse::Directory.where(discourse_category: local_category,
                                                         discourse_site: @discourse_site)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          unless vault_directories.any?
            return handle_delete_category(spin_group:,
                                          category: local_category)
          end

          options = local_categories.pluck(:name)
          options -= [local_category.name]

          vault_directories.each do |directory|
            short_path = Discourse::Utils::Ui.fancy_path(directory.path)
            selected_name = nil
            loop do
              prompt = "The category associated with {{blue:#{short_path}}} has been deleted on " \
                       "{{blue:#{@discourse_site.domain}}}. Select a new category"
              selected_name = CLI::UI::Prompt.ask(prompt, options:)
              confirm = CLI::UI::Prompt.confirm("Is #{selected_name} correct?")
              break if confirm
            end

            update_directory_category(spin_group:, directory:, categories: local_categories,
                                      category_name: selected_name)
          end
        end

        def new_category_for_directory(spin_group:, local_categories:, deleted_category:,
                                       vault_directories:)
          options = local_categories.pluck(:name)
          options -= [deleted_category.name]

          vault_directories.each do |directory|
            short_path = Discourse::Utils::Ui.fancy_path(directory.path)
            selected_name = nil
            loop do
              prompt = "The category associated with {{blue:#{short_path}}} has been deleted on " \
                       "{{blue:#{@discourse_site.domain}}}. Select a new category"
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
              raise Discourse::Errors::BaseError unless dir
            end
            spinner.update_title("Updated category for #{directory.path} to #{discourse_category.name}")
          end
          spin_group.wait

          Discourse::Utils::RecategorizeNotesFrame.call(directory:,
                                                        discourse_site: @discourse_site, api_key: @api_key)

          handle_delete_category(spin_group:, category: discourse_category)
        end

        def handle_delete_category(spin_group:, category:)
          spin_group.add("Deleting local entry for #{category.name}") do |spinner|
            Discourse::DiscourseCategory.find(category.id).destroy
            spinner.update_title("Deleted local entry for #{category.name}")
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
