# frozen_string_literal: true

require_relative 'ui_utils'
require_relative '../models/discourse_category'

module Discourse
  module Utils
    class CategorySelector
      class << self
        def call(notes)
          select_category(notes)
        end

        def category_prompt(notes)
          notes_str = Discourse::Utils::Ui.colored_text_from_array(notes, 'green')
          "Category for #{notes_str}"
        end

        def category_confirm_prompt(category)
          "Is #{category} correct?"
        end

        def select_category(notes)
          category_names = Discourse::DiscourseCategory.all.pluck(:name)
          category_name = nil
          loop do
            category_name = CLI::UI::Prompt.ask(category_prompt(notes),
                                                options: category_names)
            confirm = CLI::UI::Prompt.confirm(category_confirm_prompt(category_name))
            return Discourse::DiscourseCategory.find_by(name: category_name) if confirm
          end
        end
      end
    end
  end
end
