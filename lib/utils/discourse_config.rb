# frozen_string_literal: true

require 'uri'

module Discourse
  module Utils
    class DiscourseConfig
      class << self
        def call
          host = config_for_host
          username_for_host(host)
        end

        def base_url_prompt
          'Base URL of the Discourse site you want to connect to'
        end

        def username_prompt(host)
          "Your username on #{host}"
        end

        def username_confirm_prompt(host, username)
          "Confirm that #{username} should be used for publishing Notes to #{host}"
        end

        def config_for_host
          base_url = CLI::UI::Prompt.ask(base_url_prompt)
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
              confirm = CLI::UI::Prompt.confirm(username_confirm_prompt(host, username))
              break if confirm

              username = CLI::UI::Prompt.ask(username_prompt(host))
            end
          else
            loop do
              username = CLI::UI::Prompt.ask(username_prompt(host))
              confirm = CLI::UI::Prompt.confirm(username_confirm_prompt(host, username))
              break if confirm
            end
          end

          Discourse::Config.set(host, 'discourse_username', username)
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
