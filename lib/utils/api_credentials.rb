# frozen_string_literal: true

require 'dotenv'

require_relative 'ask_password'
require_relative 'encryption'

Dotenv.load

module Discourse
  module Utils
    class ApiCredentials
      class << self
        def call
          confirm_api_config
        end

        def credentials
          iv = ENV.fetch('IV', nil)
          salt = ENV.fetch('SALT', nil)
          encrypted_key = ENV.fetch('ENCRYPTED_KEY', nil)
          [iv, salt, encrypted_key]
        end

        def ask_password_question
          'Password to encrypt API Key'
        end

        def mismatch_prompt
          'Passwords did not match. Please try again.'
        end

        def ask_password_confirm
          'Confirm password'
        end

        def ask_api_key_question
          'Your Discourse API key'
        end

        def api_key_confirm(key_start)
          "Confirm the key starting with #{key_start} is correct"
        end

        private

        def confirm_api_config
          iv, salt, encrypted_key = credentials
          return if iv && salt && encrypted_key

          password = AskPassword.ask_and_confirm_password(ask_password_question,
                                                          mismatch_prompt,
                                                          ask_password_confirm)
          api_key_prompt(password)
        end

        def api_key_prompt(password)
          unencrypted_key, key_start = nil
          loop do
            unencrypted_key = CLI::UI::Prompt.ask_password(ask_api_key_question)
            key_start = unencrypted_key[0, 4]
            confirm = CLI::UI::Prompt
                      .confirm(api_key_confirm(key_start))

            break if confirm
          end

          iv, salt, encrypted_key = Encryption.encrypt(password, unencrypted_key)

          write_to_env('IV', iv)
          write_to_env('SALT', salt)
          write_to_env('ENCRYPTED_KEY', encrypted_key)
        end

        def write_to_env(key, value)
          file_path = File.join(Dir.pwd, '.env')
          File.open(file_path, 'a') do |file|
            file.puts "#{key}=\"#{value}\""
          end
        end
      end
    end
  end
end
