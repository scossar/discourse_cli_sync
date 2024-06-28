# frozen_string_literal: true

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

      info = category_info(categories)
      info.each do |row|
        puts row
      end
      [categories, category_names]
    end

    def self.category_info(categories)
      rows = []

      categories.each_value do |category|
        name = CLI::UI.fmt "{{blue:#{category[:name]}}}"
        read_restricted = category[:read_restricted]
        description = category[:description_excerpt]
        row = "#{name}\nread restricted: #{read_restricted}\n #{description}"
        rows << row
      end
      rows
    end
  end
end
