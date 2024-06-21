# frozen_string_literal: true

module Discourse
  module Utils
    class DiscourseConfig
      class << self
        def call
          discourse_credentials
          vault_credentials
        end

        private

        def discourse_credentials
          discourse_username = Discourse::Config.get('credentials', 'discourse_username')

          unless discourse_username
            loop do
              discourse_username = CLI::UI::Prompt.ask("What's your Discourse username?")

              confirm = CLI::UI::Prompt.confirm("Confirm that #{discourse_username} is correct")

              break if confirm
            end
          end

          Discourse::Config.set('credentials', 'discourse_username', discourse_username)
        end

        def vault_credentials
          vault_dir = Discourse::Config.get('vault', 'vault_dir')

          unless vault_dir
            loop do
              vault_dir = CLI::UI::Prompt.ask('What directory is your Obsidian Vault in?')
              confirm = CLI::UI::Prompt.confirm("Confirm that #{vault_dir} is correct")

              break if confirm
            end
          end
          Discourse::Config.set('vault', 'vault_dir', vault_dir)
        end
      end
    end
  end
end
