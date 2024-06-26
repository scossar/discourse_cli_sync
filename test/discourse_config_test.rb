# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/utils/discourse_config'

module Discourse
  module Utils
    class DiscourseConfigTest < Minitest::Test
      include CLI::Kit::Support::TestHelper
      include FakeConfig

      def setup
        super
        Discourse::Config.set('discourse', 'base_url', nil)
        Discourse::Config.set('credentials', 'discourse_username', nil)
        Discourse::Config.set('vault', 'vault_dir', nil)
      end

      def test_username_not_set
        mock_username_prompt('scossar')
        mock_username_confirm('scossar')
        mock_vault_prompt('~/Vault')
        mock_vault_confirm('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_username_set
        Discourse::Config.set('credentials', 'discourse_username', 'scossar')

        CLI::UI::Prompt.expects(:ask).with("What's your Discourse username?").never
        CLI::UI::Prompt.expects(:confirm).with('Confirm that scossar is correct').never
        mock_vault_prompt('~/Vault')
        mock_vault_confirm('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_vault_dir_not_set
        mock_username_prompt('scossar')
        mock_username_confirm('scossar')
        mock_vault_prompt('~/Vault')
        mock_vault_confirm('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal '~/Vault', Discourse::Config.get('vault', 'vault_dir')
      end

      def test_vault_dir_set
        Discourse::Config.set('vault', 'vault_dir', '~/Vault')
        CLI::UI::Prompt.expects(:ask).with('What directory is your Obsidian Vault in?').never
        mock_username_prompt('scossar')
        mock_username_confirm('scossar')
        CLI::UI::Prompt.expects(:confirm).with('Confirm that ~/Vault is correct').never

        Discourse::Utils::DiscourseConfig.call

        assert_equal '~/Vault', Discourse::Config.get('vault', 'vault_dir')
      end

      private

      def mock_username_prompt(return_value)
        CLI::UI::Prompt.expects(:ask).with("What's your Discourse username?")
                       .returns(return_value).at_least_once
      end

      def mock_username_confirm(username)
        CLI::UI::Prompt.expects(:confirm).with("Confirm that #{username} is correct")
                       .returns(true).at_least_once
      end

      def mock_vault_prompt(return_value)
        CLI::UI::Prompt.expects(:ask).with('What directory is your Obsidian Vault in?')
                       .returns(return_value).at_least_once
      end

      def mock_vault_confirm(vault)
        CLI::UI::Prompt.expects(:confirm).with("Confirm that #{vault} is correct")
                       .returns(true).at_least_once
      end
    end
  end
end
