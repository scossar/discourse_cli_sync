# frozen_string_literal: true

require 'uri'

module Discourse
  module Utils
    class DiscourseConfig
      class << self
        def call
          host = config_for_host
          username_for_host(host)
          vault_dir_for_host(host)
          host
        end

        def base_url_prompt
          'Base URL of the Discourse site you want to connect to'
        end

        def base_url_confirm_prompt(base_url)
          "Confirm that #{base_url} is correct"
        end

        def username_prompt(host)
          "Your username on #{host}"
        end

        def username_confirm_prompt(host, username)
          "Confirm that #{username} should be used for publishing Notes to #{host}"
        end

        def vault_dir_prompt(host)
          "Local vault directory to use for #{host}"
        end

        def vault_dir_confirm_prompt(host, vault_dir)
          "Confirm that #{vault_dir} is the correct directory to use for #{host}"
        end

        def config_for_host
          base_url = nil
          loop do
            base_url = ask(base_url_prompt)
            confirm = confirm(base_url_confirm_prompt(base_url))
            break if confirm
          end
          host = extract_host(base_url)
          host_configured = Discourse::Config.get(host, base_url) && base_url == host_configured

          return host if host_configured

          Discourse::Config.set(host, 'base_url', base_url)
          host
        end

        def username_for_host(host)
          username = Discourse::Config.get(host, 'discourse_username')

          if username
            loop do
              confirm = confirm(username_confirm_prompt(host, username))
              break if confirm

              username = ask(username_prompt(host))
            end
          else
            loop do
              username = ask(username_prompt(host))
              confirm = confirm(username_confirm_prompt(host, username))
              break if confirm
            end
          end

          Discourse::Config.set(host, 'discourse_username', username)
        end

        def vault_dir_for_host(host)
          vault_dir = Discourse::Config.get(host, 'vault_directory')

          if vault_dir
            loop do
              confirm = ask(vault_dir_confirm_prompt(host, vault_dir))
              break if confirm

              vault_dir = ask(vault_dir_prompt(host))
            end
          else
            loop do
              vault_dir = ask(vault_dir_prompt(host))
              confirm = confirm(vault_dir_confirm_prompt(host, vault_dir))
              break if confirm
            end
          end

          Discourse::Config.set(host, 'vault_directory', vault_dir)
        end

        def ask(prompt)
          CLI::UI::Prompt.ask(prompt)
        end

        def confirm(prompt)
          CLI::UI::Prompt.confirm(prompt)
        end

        def extract_host(url)
          # TODO: handle errors
          uri = URI.parse(url)
          uri.host
        end
      end
    end
  end
end
