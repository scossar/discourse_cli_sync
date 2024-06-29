# frozen_string_literal: true

require_relative 'ui_utils'

module Discourse
  module Utils
    class CategorySelector
      class << self
        def call(categories, notes)
          select_category(categories, notes)
        end

        def category_prompt(notes)
          notes_str = Discourse::Utils::Ui.colored_text_from_array(notes, 'green')
          "Category for #{notes_str}"
        end

        def category_confirm_prompt(category)
          "Is #{category} correct?"
        end

        def select_category(categories, notes)
          category = nil
          loop do
            category = CLI::UI::Prompt.ask(category_prompt(notes),
                                           options: category_names(categories))
            confirm = CLI::UI::Prompt.confirm(category_confirm_prompt(category))
            return category_id_by_name(categories, category) if confirm
          end
        end

        def category_names(categories)
          categories.values.map { |category| category[:name] }
        end

        def category_id_by_name(categories, name)
          categories.each do |id, category|
            return id if category[:name] == name
          end
        end
      end
    end
  end
end
