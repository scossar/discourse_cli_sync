# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/utils/api_credentials'

module Discourse
  module Utils
    class ApiCredentialsTest < Minitest::Test
      include CLI::Kit::Support::TestHelper
      include FakeConfig

      def setup
        super
        Discourse::Config.set('credentials', 'encrypted_api_key', nil)
      end

      def skip_test_api_key_set
        Discourse::Config.set('credentials', 'encrypted_api_key', '12345')
        CLI::UI::Prompt.expects(:ask).with(api_key_question).never

        Discourse::Utils::ApiCredentials.call
      end

      def test_api_key_not_set
        CLI::UI::Prompt.expects(:ask_password).with(api_key_question).returns(api_key).at_least_once
        CLI::UI::Prompt.expects(:confirm).with(confirm_question).returns(true).at_least_once

        Discourse::Utils::ApiCredentials.call

        # Not testing the saved value of the key here. Users will supply the unencrypted key, the key will
        # then be encrypted and saved.
      end

      def test_api_key_encrypted
        # encrypt the key
      end

      private

      def api_key
        '01234567' * 4
      end

      def api_key_question
        'Enter your Discourse API key'
      end

      def confirm_question
        'Is that correct?'
      end
    end
  end
end
