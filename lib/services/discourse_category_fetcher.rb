# frozen_string_literal: true

require_relative 'discourse_request'

module Discourse
  class DiscourseCategoryFetcher
    attr_reader :categories

    def initialize(site, api_key)
      @categories = fetch_categories(site, api_key)
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

    def category_by_id(category_id)
      @categories.each do |id, category|
        return category if id == category_id
      end
      nil
    end

    private

    def fetch_categories(site, api_key)
      client = DiscourseRequest.new(site, api_key)
      site_info = client.site_info
      categories = site_info['categories']
      parsed_categories = parse_categories(categories)
      fix_category_names(parsed_categories)
    end

    # TODO: not sure about the use of each_with_object here:
    def parse_categories(categories)
      categories.each_with_object({}) do |cat, result|
        cat_hash = cat.to_h
        result[cat_hash['id']] = {
          id: cat_hash['id'],
          name: cat_hash['name'],
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
