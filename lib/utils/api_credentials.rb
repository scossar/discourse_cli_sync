# frozen_string_literal: true

require_relative 'ask_password'
require_relative 'encryption'
require_relative '../models/discourse_site'

require_relative 'logger'

module Discourse
  module Utils
    class ApiCredentials
      class << self
        def call(discourse_site)
          domain = discourse_site.domain
          credentials_for_site(discourse_site, domain)
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

        def api_key_prompt(domain)
          "Your Discourse API key for #{domain}"
        end

        def api_key_confirm_prompt(domain, truncated_key)
          "Confirm that the key starting with #{truncated_key} is correct for #{domain}"
        end

        def credentials(discourse_site)
          [discourse_site&.iv, discourse_site&.salt, discourse_site&.encrypted_api_key]
        end

        def credentials_for_site(discourse_site, domain)
          iv, salt, encrypted_api_key = credentials(discourse_site)

          if iv && salt && encrypted_api_key
            puts CLI::UI.fmt "Api credentials are configured for #{domain}"
            nil
          else
            password = AskPassword.ask_and_confirm_password(ask_password_prompt,
                                                            password_confirm_prompt,
                                                            password_mismatch_prompt)
            set_api_key(discourse_site:, domain:, password:)
            password
          end
        end

        def set_api_key(discourse_site:, domain:, password:)
          unencrypted_key, key_start = nil
          loop do
            unencrypted_key = ask_password(api_key_prompt(domain))
            key_start = unencrypted_key[0, 4]
            confirm = confirm(api_key_confirm_prompt(domain, key_start))
            break if confirm
          end
          iv, salt, encrypted_api_key = Encryption.encrypt(password, unencrypted_key)
          discourse_site.update(iv:, salt:, encrypted_api_key:)
          password
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
