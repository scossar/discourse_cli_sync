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
        Discourse::Config.set('credentials', 'discourse_username', nil)
        Discourse::Config.set('vault', 'vault_dir', nil)
      end

      def test_username_not_set
        mock_discourse_prompt('scossar')
        mock_vault_prompt('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_username_set
        Discourse::Config.set('credentials', 'discourse_username', 'scossar')
        CLI::UI::Prompt.expects(:ask).with("What's your Discourse username?").never
        mock_vault_prompt('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_vault_dir_not_set
        mock_discourse_prompt('scossar')
        mock_vault_prompt('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal '~/Vault', Discourse::Config.get('vault', 'vault_dir')
      end

      def test_vault_dir_set
        Discourse::Config.set('vault', 'vault_dir', '~/Vault')
        CLI::UI::Prompt.expects(:ask).with('What directory is your Obsidian Vault in?').never
        mock_discourse_prompt('scossar')

        Discourse::Utils::DiscourseConfig.call

        assert_equal '~/Vault', Discourse::Config.get('vault', 'vault_dir')
      end

      private

      def mock_discourse_prompt(return_value)
        CLI::UI::Prompt.expects(:ask).with("What's your Discourse username?")
                       .returns(return_value).at_least_once
      end

      def mock_vault_prompt(return_value)
        CLI::UI::Prompt.expects(:ask).with('What directory is your Obsidian Vault in?')
                       .returns(return_value).at_least_once
      end
    end
  end
end
