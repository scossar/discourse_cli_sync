# frozen_string_literal: true

module Discourse
  module Utils
    class DiscourseConfig
      class << self
        def call
          discourse_site
          discourse_credentials
          vault_credentials
        end

        def base_url_prompt
          "The Discourse site's base URL"
        end

        def base_url_confirm(base_url)
          "Is #{base_url} correct?"
        end

        def discourse_username_prompt
          "What's your Discourse username"
        end

        def discourse_username_confirm(username)
          "Is #{username} correct?"
        end

        def vault_dir_prompt
          'What directory is your Obsidian Vault in?'
        end

        def vault_dir_confirm(dir)
          "Is #{dir} correct?"
        end

        private

        def discourse_site
          base_url = Discourse::Config.get('discourse', 'base_url')

          unless base_url
            loop do
              base_url = CLI::UI::Prompt.ask(base_url_prompt)

              confirm = CLI::UI::Prompt.confirm(base_url_confirm(base_url))

              break if confirm
            end
          end

          Discourse::Config.set('discourse', 'base_url', base_url)
        end

        def discourse_credentials
          discourse_username = Discourse::Config.get('credentials', 'discourse_username')

          unless discourse_username
            loop do
              discourse_username = CLI::UI::Prompt.ask(discourse_username_prompt)

              confirm = CLI::UI::Prompt.confirm(discourse_username_confirm(discourse_username))

              break if confirm
            end
          end

          Discourse::Config.set('credentials', 'discourse_username', discourse_username)
        end

        def vault_credentials
          vault_dir = Discourse::Config.get('vault', 'vault_dir')

          unless vault_dir
            loop do
              vault_dir = CLI::UI::Prompt.ask(vault_dir_prompt)
              confirm = CLI::UI::Prompt.confirm(vault_dir_confirm(vault_dir))

              break if confirm
            end
          end
          Discourse::Config.set('vault', 'vault_dir', vault_dir)
        end
      end
    end
  end
end
