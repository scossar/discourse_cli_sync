# frozen_string_literal: true

require_relative 'api_credentials'
require_relative 'encryption'

module Discourse
  module Utils
    module ApiKey
      def self.api_key
        iv, salt, encrypted_key = ApiCredentials.ask_password
        password = CLI::UI::Prompt
                   .ask_password('Api Key password')
        Encryption.decrypt(password, salt, iv, encrypted_key)
      end
    end
  end
end
