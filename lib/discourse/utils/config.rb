# frozen_string_literal: true

module Discourse
  module Utils
    class Config
      class << self
        def check_config
          discourse_username = Discourse::Config.get('credentials', 'discourse_username')

          discourse_username ||= CLI::UI::Prompt.ask("What's your Discourse username?")
          Discourse::Config.set('credentials', 'discourse_username', discourse_username)
        end
      end
    end
  end
end
