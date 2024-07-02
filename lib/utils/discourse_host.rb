# frozen_string_literal: true

require 'uri'

require_relative '../models/encrypted_credential'

module Discourse
  module Utils
    class DiscourseHost
      class << self
        def call
          host = configuration_for_host
        end

        def configuration_for_host
          hosts = configured_hosts
          if hosts.any?
            host = confirm_config(hosts[0]) if hosts.length == 1
            host = select_host(hosts) if hosts.length > 1
          else
            host = configure_host
          end
          host
        end

        def confirm_config(host)
          use_existing = CLI::UI::Prompt.confirm("Use existing configuration for #{host}?")
          if use_existing
            base_url, discourse_username, vault_directory = config_for_host(host)
            confirm_credentials(host:, base_url:, discourse_username:, vault_directory:)
          else
            add_new_host
          end
        end

        def confirm_credentials(host:, base_url:, discourse_username:, vault_directory:)
          confirm_prompt = CLI::UI.fmt("Are these values correct?\n  " \
                                       "base_url: #{base_url}\n  " \
                                       "discourse_username: #{discourse_username}\n  " \
                                       "vault_directory: #{vault_directory}")
          confirm = CLI::UI::Prompt.confirm(confirm_prompt)

          if confirm
            host
          else
            update_config(host)
          end
        end

        def update_config(host)
          puts CLI::UI.fmt "Update configuration for #{host}"
          configure_host(host)
        end

        def add_new_host
          puts CLI::UI.fmt 'Add new Discourse host'
          configure_host
        end

        def configure_host(host = nil)
          host = base_url(host)
          discourse_username(host)
          vault_directory(host)
        end

        def base_url(host = nil)
          base_url_prompt = if host
                              "Base URL for #{host}"
                            else
                              "The Discourse site's base URL"
                            end

          base_url = nil
          error_message = ''
          loop do
            base_url = CLI::UI::Prompt.ask(base_url_prompt)
            host, error_message = extract_host(base_url)
            if error_message
              puts CLI::UI.fmt error_message
            else
              confirm = CLI::UI::Prompt.confirm("Is #{base_url} correct?")
            end
            break if confirm && host && error_message.empty?
          end

          host
        end

        def discourse_username(host)
          discourse_username = nil
          loop do
            discourse_username = CLI::UI::Prompt.ask("Discourse username for #{host}?")
            confirm = CLI::UI::Prompt.confirm("Is #{discourse_username} correct?")
            break if confirm
          end

          Discourse::Config.add(host, 'discourse_username', discourse_username)
        end

        def vault_directory(host)
          vault_directory = nil
          loop do
            vault_directory = CLI::UI::Prompt.ask("Vault directory for #{host}")
            confirm = CLI::UI::Prompt.confirm("Is #{vault_directory} correct?")
            break if confirm
          end

          Discourse::Config.add(host, 'vault_directory', vault_directory)
        end

        def configured_hosts
          Discourse::EncryptedCredential.all&.pluck(:host)
        end

        def config_for_host(host)
          base_url = Discourse::Config.get(host, 'base_url')
          discourse_username = Discourse::Config.get(host, 'discourse_username')
          vault_directory = Discourse::Config.get(host, 'vault_directory')
          [base_url, discourse_username, vault_directory]
        end

        def extract_host(url)
          uri = URI.parse(url)
          host = uri.host
          return [nil, "A domain cannot be extracted from #{url}"] if host.nil?

          [host, '']
        rescue URI::InvalidURIError => e
          [nil, "Invalid URI: #{e.message}"]
        end
      end
    end
  end
end
