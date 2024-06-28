# frozen_string_literal: true

require_relative 'discourse_request'

module Discourse
  class DiscourseCategoryFetcher
    attr_reader :categories

    def initialize(host, api_key)
      @categories = fetch_categories(host, api_key)
    end

    def category_names
      @categories.values.map { |category| category[:name] }
    end

    def category_id_by_name(name)
      @categories.each do |id, category|
        return id if category[:name] == name
      end
      nil
    end

    private

    def fetch_categories(host, api_key)
      client = DiscourseRequest.new(host, api_key)
      site_info = client.site_info
      categories = site_info['categories']
      parsed_categories = parse_categories(categories)
      fix_category_names(parsed_categories)
    end

    def parse_categories(categories)
      categories.each_with_object({}) do |cat, result|
        cat_hash = cat.to_h
        result[cat_hash['id']] = {
          id: cat_hash['id'],
          name: cat_hash['name'],
          slug: cat_hash['slug'],
          read_restricted: cat_hash['read_restricted'],
          parent_category_id: cat_hash['parent_category_id'],
          description_excerpt: cat_hash['description_excerpt']
        }
      end
    end

    def fix_category_names(parsed_categories)
      parsed_categories.each_value do |category|
        if category[:parent_category_id]
          parent_category = parsed_categories[category[:parent_category_id]]
          category[:name] = "#{parent_category[:name]}/#{category[:name]}"
        end
      end
      parsed_categories
    end
  end
end
