# frozen_string_literal: true

module Discourse
  module Utils
    class DiscourseConfig
      class << self
        def call
          check_discourse_credentials
          check_vault_credentials
        end

        private

        def check_discourse_credentials
          discourse_username = Discourse::Config.get('credentials', 'discourse_username')

          return if discourse_username

          discourse_username = CLI::UI::Prompt.ask("What's your Discourse username?")
          Discourse::Config.set('credentials', 'discourse_username', discourse_username)
        end

        def check_vault_credentials
          vault_dir = Discourse::Config.get('vault', 'vault_dir')

          return if vault_dir

          vault_dir = CLI::UI::Prompt.ask('What directory is your Obsidian Vault in?')
          Discourse::Config.set('vault', 'vault_dir', vault_dir)
        end
      end
    end
  end
end
