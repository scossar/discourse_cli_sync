# frozen_string_literal: true

require_relative 'encryption'

module Discourse
  module Utils
    module ApiKey
      def self.api_key
        iv, salt, encrypted_key = credentials
        password = CLI::UI::Prompt
                   .ask_password('Api Key password')
        Encryption.decrypt(password, salt, iv, encrypted_key)
      end

      def self.credentials
        iv = Discourse::Config.get('api', 'iv')
        salt = Discourse::Config.get('api', 'salt')
        encrypted_key = Discourse::Config.get('api', 'encrypted_key')
        [iv, salt, encrypted_key]
      end
    end
  end
end
