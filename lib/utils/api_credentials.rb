# frozen_string_literal: true

require_relative 'ask_password'
require_relative 'encryption'
require_relative '../models/encrypted_credential'

module Discourse
  module Utils
    class ApiCredentials
      class << self
        def call(host)
          # something
        end

        def ask_password_prompt
          'Password to encrypt API key'
        end

        def password_confirm_prompt
          'Confirm password'
        end

        def password_mismatch_prompt
          'Passwords did not match. Please try again'
        end

        def api_key_prompt(host)
          "Your Discourse API key for #{host}"
        end

        def api_key_confirm_prompt(host, truncated_key)
          "Confirm that the key starting with #{truncated_key} is correct for #{host}"
        end

        def credentials(host)
          encrypted_credentials = EncryptedCredential.find_by(host:)

          [nil, nil, nil] unless encrypted_credentials

          iv = encrypted_credentials.iv
          salt = encrypted_credentials.salt
          encrypted_api_key = encrypted_credentials.api_key
          [iv, salt, encrypted_api_key]
        end

        def credentials_for_host(host)
          iv, salt, encrypted_api_key = credentials(host)

          if iv && salt && encrypted_api_key
            CLI::UI.fmt "Api credentials are configured for #{host}"
          else
            password = AskPassword.ask_and_confirm_password(ask_password_prompt,
                                                            password_confirm_prompt,
                                                            password_mismatch_prompt)
            set_api_key(password)
            password
          end
        end

        def set_api_key(host, password)
          unencrypted_key, key_start = nil
          loop do
            unencrypted_key = ask_password(api_key_prompt(host))
            key_start = unencrypted_key[0, 4]
            confirm = confirm(api_key_confirm_prompt(host, key_start))
            break if confirm
          end
          iv, salt, encrypted_api_key = Encryption.encrypt(password, unencrypted_key)
          EncryptedCredential.create(host:, iv:, salt:, encrypted_api_key:)
        end

        def ask_password(prompt)
          CLI::UI::Prompt.ask_password(prompt)
        end

        def confirm(prompt)
          CLI::UI::Prompt.confirm(prompt)
        end
      end
    end
  end
end
