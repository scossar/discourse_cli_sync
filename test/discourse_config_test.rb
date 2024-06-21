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
      end

      def test_username_not_set
        CLI::UI::Prompt.expects(:ask).with("What's your Discourse username?").returns('scossar')

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_username_set
        Discourse::Config.set('credentials', 'discourse_username', 'scossar')
        CLI::UI::Prompt.expects(:ask).with("What's your Discourse username?").never

        Discourse::Utils::DiscourseConfig.call

        assert_equal 'scossar', Discourse::Config.get('credentials', 'discourse_username')
      end

      def test_vault_dir_not_set
        CLI::UI::Prompt.expects(:ask).with("What's the directory of your Obsidian Vault?")
                       .returns('~/Vault')

        Discourse::Utils::DiscourseConfig.call

        assert_equal '~/Vault', DiscourseConfig.get('vault', 'vault_dir')
      end
    end
  end
end
