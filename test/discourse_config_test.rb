# frozen_string_literal: true

require_relative 'test_helper'

module Discourse
  module Utils
    class DiscourseConfigTest < Minitest::Test
      include CLI::Kit::Support::TestHelper
      include CLI::Kit::Support::TestHelper::FakeConfig

      # Leaving this in place for reference
      def test_fake_config
        Discourse::Config.set('credentials', 'discourse_username', 'foo')
        discourse_username = Discourse::Config.get('credentials', 'discourse_username')
        assert_equal discourse_username, 'foo', 'The discourse_username should be set to foo'
      end
    end
  end
end
