# frozen_string_literal: true

module Discourse
  module Utils
    class DiscourseConfig
      def self.call
        check_config
      end

      def self.check_config
        discourse_username = Discourse::Config.get('credentials', 'discourse_username')

        discourse_username ||= CLI::UI::Prompt.ask("What's your Discourse username?")
        Discourse::Config.set('credentials', 'discourse_username', discourse_username)
      end
    end
  end
end
