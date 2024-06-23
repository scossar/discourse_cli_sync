# frozen_string_literal: true

module Discourse
  module Utils
    class ApiCredentials
      class << self
        def call
          api_key
        end

        private

        def api_key
          encrypted_key = Discourse::Config.get('credentials', 'encrypted_api_key')

          unless encrypted_key
            loop do
              encrypted_key = CLI::UI::Prompt.ask_password('Enter your Discourse API key')
              confirm = CLI::UI::Prompt.confirm('Is that correct?')

              break if confirm
            end
          end
          # call some function that encrypts the key

          Discourse::Config.set('credentials', 'encrypted_api_key', encrypted_key)
        end
      end
    end
  end
end
