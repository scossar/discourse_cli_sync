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
        Discourse::Config.set('discourse_site', 'base_url', nil)
        Discourse::Config.set('credentials', 'discourse_username', nil)
        Discourse::Config.set('vault', 'vault_dir', nil)
      end

      def test_unconfigured
        mock_base_url_prompt('https://discourse.example.com')
        mock_base_url_confirm('https://discourse.example.com')
        mock_username_prompt('scossar')
        mock_username_confirm('scossar')
        mock_vault_prompt('~/Vault')
        mock_vault_confirm('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_username_set
        Discourse::Config.set('credentials', 'discourse_username', 'scossar')

        mock_base_url_prompt('https://discourse.example.com')
        mock_base_url_confirm('https://discourse.example.com')
        CLI::UI::Prompt.expects(:ask).with(Discourse::Utils::DiscourseConfig.discourse_username_prompt).never
        CLI::UI::Prompt.expects(:confirm).with(Discourse::Utils::DiscourseConfig.discourse_username_confirm('scossar')).never
        mock_vault_prompt('~/Vault')
        mock_vault_confirm('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_vault_dir_not_set
        mock_base_url_prompt('https://discourse.example.com')
        mock_base_url_confirm('https://discourse.example.com')
        mock_username_prompt('scossar')
        mock_username_confirm('scossar')
        mock_vault_prompt('~/Vault')
        mock_vault_confirm('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal '~/Vault', Discourse::Config.get('vault', 'vault_dir')
      end

      def test_vault_dir_set
        mock_base_url_prompt('https://discourse.example.com')
        mock_base_url_confirm('https://discourse.example.com')
        mock_username_prompt('scossar')
        mock_username_confirm('scossar')
        Discourse::Config.set('vault', 'vault_dir', '~/Vault')
        CLI::UI::Prompt.expects(:ask).with(Discourse::Utils::DiscourseConfig.vault_dir_prompt).never
        CLI::UI::Prompt.expects(:confirm).with(Discourse::Utils::DiscourseConfig.vault_dir_confirm('~/Vault')).never

        Discourse::Utils::DiscourseConfig.call

        assert_equal '~/Vault', Discourse::Config.get('vault', 'vault_dir')
      end

      private

      def mock_base_url_prompt(base_url)
        CLI::UI::Prompt.expects(:ask).with(Discourse::Utils::DiscourseConfig.base_url_prompt)
                       .returns(base_url).at_least_once
      end

      def mock_base_url_confirm(base_url)
        CLI::UI::Prompt.expects(:confirm).with(Discourse::Utils::DiscourseConfig.base_url_confirm(base_url))
                       .returns(true).at_least_once
      end

      def mock_username_prompt(return_value)
        CLI::UI::Prompt.expects(:ask).with(Discourse::Utils::DiscourseConfig.discourse_username_prompt)
                       .returns(return_value).at_least_once
      end

      def mock_username_confirm(username)
        CLI::UI::Prompt.expects(:confirm).with(Discourse::Utils::DiscourseConfig.discourse_username_confirm(username))
                       .returns(true).at_least_once
      end

      def mock_vault_prompt(return_value)
        CLI::UI::Prompt.expects(:ask).with(Discourse::Utils::DiscourseConfig.vault_dir_prompt)
                       .returns(return_value).at_least_once
      end

      def mock_vault_confirm(vault)
        CLI::UI::Prompt.expects(:confirm).with(Discourse::Utils::DiscourseConfig.vault_dir_confirm(vault))
                       .returns(true).at_least_once
      end
    end
  end
end
