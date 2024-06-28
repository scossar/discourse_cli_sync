# frozen_string_literal: true

require 'terminal-table'

require_relative '../services/discourse_category_fetcher'

module Discourse
  module UI
    def self.category_loader(host, api_key)
      fetcher = DiscourseCategoryFetcher.new(host, api_key)

      spin_group = CLI::UI::SpinGroup.new

      spin_group.failure_debrief do |_title, exception|
        puts CLI::UI.fmt "  #{exception}"
      end

      categories, category_names = nil
      spin_group.add('Categories') do
        categories = fetcher.categories
        category_names = fetcher.category_names
      end

      spin_group.wait

      category_info(categories)
      [categories, category_names]
    end

    def self.category_info(categories)
      rows = []

      categories.each_value do |category|
        name = CLI::UI.fmt "{{blue:#{category[:name]}}}"
        read_restricted = category[:read_restricted]
        description = category[:description_excerpt]
        rows << [name, read_restricted, description]
      end

      # TODO: be careful with this. Have a look at CLI::UI::Terminal for ideas
      table = Terminal::Table.new(headings: ['Name', 'Read Restricted', 'Description'],
                                  rows:)
      table.style = { border: :unicode_round }
      puts table
    end
  end
end
