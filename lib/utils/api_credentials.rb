# frozen_string_literal: true

require_relative 'encryption'

module Discourse
  module Utils
    class ApiCredentials
      class << self
        def call
          encrypted_key = Discourse::Config.get('api', 'encrypted_key')
          initialization_vector = Discourse::Config.get('api', 'iv')

          return if encrypted_key && initialization_vector

          encryption_password = CLI::UI::Prompt
                                .ask('Password to use for API Key encryption?')
          password_confirm = CLI::UI::Prompt.ask('Enter encryption password again')
          unless encryption_password == password_confirm
            throw new StandardError "Passwords don't match"
          end

          cipher_key = Encryption.cipher_key_from_password(encryption_password)

          unencrypted_key, key_start = nil
          loop do
            unencrypted_key = CLI::UI::Prompt.ask('Your Discourse API key')
            key_start = unencrypted_key[0, 4]
            confirm = CLI::UI::Prompt
                      .confirm("Confirm that the key starting with #{key_start} is correct")

            break if confirm
          end

          puts "unencrypted_key: #{unencrypted_key}, cipher_key: #{cipher_key}"
          encrypted_key, iv = Encryption.encrypt_api_key(unencrypted_key, cipher_key)

          Discourse::Config.set('api', 'encrypted_key', encrypted_key)
          Discourse::Config.set('api', 'iv', iv)
        end
      end
    end
  end
end
