# frozen_string_literal: true

module Discourse
  module Utils
    module Ui
      def self.colored_text_from_array(array, color)
        colored = array.map { |item| "{{#{color}:#{item}}}" }
        colored.join(', ')
      end

      def self.fancy_path(expanded_path)
        expanded_path.gsub(/^#{Regexp.escape(Dir.home)}/, '~')
      end
    end
  end
end
