# frozen_string_literal: true

require_relative '../models/discourse_site'

module Discourse
  module Utils
    class ConfigureSite
      class << self
        def call
          configure_discourse_site
        end

        def configure_discourse_site
          domains = configured_domains

          if domains.any?
            select_site(domains)
          else
            add_site
          end
        end

        def select_site(domains)
          options =  domains << 'add new site'
          selected = nil
          loop do
            selected = CLI::UI::Prompt.ask('Select existing site, or add a new one', options:)
            confirm = CLI::UI::Prompt.confirm("You chose #{selected}. Is that correct?")
            break if confirm
          end

          if selected == 'add new site'
            add_site
          else
            confirm_site(selected)
          end
        end

        def add_site
          domain, base_url = configure_base_url
          discourse_username = configure_username(domain)
          vault_directory = configure_vault_directory(domain)
          Discourse::DiscourseSite.create(domain:, base_url:, discourse_username:,
                                          vault_directory:)
        end

        def confirm_site(domain)
          site = Discourse::DiscourseSite.find_by(domain:)
          discourse_username, vault_directory = config_for_site(site)
          confirm_prompt = CLI::UI.fmt("Existing configuration for #{domain}\n  " \
                                       "discourse_username: #{discourse_username}\n  " \
                                       "vault_directory: #{vault_directory}\n" \
                                       'Are these values correct?')
          confirm = CLI::UI::Prompt.confirm(confirm_prompt)
          return site if confirm

          update_config(domain:, discourse_username:, vault_directory:)
        end

        def update_config(domain:, discourse_username:, vault_directory:)
          site = Discourse::DiscourseSite.find_by(domain:)
          update_username = CLI::UI::Prompt.confirm("Update username: #{discourse_username}?")
          discourse_username = configure_username(domain) if update_username
          update_vault_directory = CLI::UI::Prompt.confirm("Update vault directory: #{vault_directory}?")
          vault_directory = configure_vault_directory(domain) if update_vault_directory
          if update_username || update_vault_directory
            site.update(discourse_username:, vault_directory:)
          end
          site
        end

        def configure_base_url
          base_url, domain = nil
          loop do
            base_url = CLI::UI::Prompt.ask('Discourse base URL')
            domain, error_message = extract_domain(base_url)
            confirm = CLI::UI::Prompt.confirm("Is #{domain} correct?") if domain
            break if confirm

            puts CLI::UI.fmt(error_message)
          end

          [domain, base_url]
        end

        def configure_username(domain)
          discourse_username = nil
          loop do
            discourse_username = CLI::UI::Prompt.ask("Discourse username for #{domain}?")
            confirm = CLI::UI::Prompt.confirm("Is #{discourse_username} correct?")
            break if confirm
          end

          discourse_username
        end

        def configure_vault_directory(domain)
          vault_directory = nil
          loop do
            vault_directory = CLI::UI::Prompt.ask("Vault directory for #{domain}")
            confirm = CLI::UI::Prompt.confirm("Is #{vault_directory} correct?")
            break if confirm
          end

          vault_directory
        end

        private

        def configured_domains
          Discourse::DiscourseSite.all&.pluck(:domain)
        end

        def config_for_site(site)
          [site.discourse_username, site.vault_directory]
        end

        def extract_domain(url)
          uri = URI.parse(url)
          host = uri.host
          return [nil, "A domain could not be extracted from #{url}"] if host.nil?

          [host, '']
        rescue URI::InvalidURIError => e
          [nil, "Invalid URI: #{e.message}"]
        end
      end
    end
  end
end
