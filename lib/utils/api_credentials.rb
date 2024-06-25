# frozen_string_literal: true

require_relative 'ask_password'
require_relative 'encryption'

module Discourse
  module Utils
    class ApiCredentials
      class << self
        def call
          confirm_api_config
        end

        def confirm_api_config
          iv, salt, encrypted_key = credentials
          return if iv && salt && encrypted_key

          password = AskPassword.ask_and_confirm_password('Password to encrypt API Key',
                                                          'Confirm password')
          unencrypted_key, key_start = nil
          loop do
            unencrypted_key = CLI::UI::Prompt.ask_password('Your Discourse API key')
            key_start = unencrypted_key[0, 4]
            confirm = CLI::UI::Prompt
                      .confirm("Confirm that the key starting with #{key_start} is correct")

            break if confirm
          end

          iv, salt, encrypted_key = Encryption.encrypt(password, unencrypted_key)

          Discourse::Config.set('api', 'iv', iv)
          Discourse::Config.set('api', 'salt', salt)
          Discourse::Config.set('api', 'encrypted_key', encrypted_key)
        end

        def credentials
          iv = Discourse::Config.get('api', 'iv')
          salt = Discourse::Config.get('api', 'salt')
          encrypted_key = Discourse::Config.get('api', 'encrypted_key')
          [iv, salt, encrypted_key]
        end
      end
    end
  end
end
