# frozen_string_literal: true

require_relative '../models/encrypted_credential'

module Discourse
  module Utils
    class ConfigureHost
      class << self
        def call
          confirm_or_configure_host
        end

        def confirm_or_configure_host
          hosts = configured_hosts

          if hosts.any?
            select_host(hosts)
          else
            add_host
          end
        end

        def select_host(hosts)
          options =  hosts << 'add new host'
          selected = nil
          loop do
            selected = CLI::UI::Prompt.ask('Select existing host, or add a new one', options:)
            confirm = CLI::UI::Prompt.confirm("You chose #{selected}. Is that correct?")
            break if confirm
          end

          if selected == 'add new host'
            add_host
          else
            confirm_host(selected)
          end
        end

        def add_host
          host = base_url
          username(host)
          vault_directory(host)
          host
        end

        def confirm_host(host)
          base_url, discourse_username, vault_directory = config_for_host(host)
        end

        def base_url
          base_url, host = nil
          loop do
            base_url = CLI::UI::Prompt.ask('Discourse base URL')
            host, error_message = extract_host(base_url)
            confirm = CLI::UI::Prompt.confirm("Is #{host} correct?") if host
            break if confirm

            puts CLI::UI.fmt(error_message)
          end

          Discourse::Config.set(host, 'base_url', base_url)
          host
        end

        def username(host)
          discourse_username = nil
          loop do
            discourse_username = CLI::UI::Prompt.ask("Discourse username for #{host}?")
            confirm = CLI::UI::Prompt.confirm("Is #{discourse_username} correct?")
            break if confirm
          end

          Discourse::Config.set(host, 'discourse_username', discourse_username)
        end

        def vault_directory(host)
          vault_directory = nil
          loop do
            vault_directory = CLI::UI::Prompt.ask("Vault directory for #{host}")
            confirm = CLI::UI::Prompt.confirm("Is #{vault_directory} correct?")
            break if confirm
          end

          Discourse::Config.set(host, 'vault_directory', vault_directory)
        end

        private

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
