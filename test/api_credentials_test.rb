# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/utils/api_credentials'
require_relative '../lib/utils//api_key'
require_relative '../lib/utils/ask_password'

module Discourse
  module Utils
    class ApiCredentialsTest < Minitest::Test
      include CLI::Kit::Support::TestHelper
      include FakeConfig

      def setup
        super
        Discourse::Config.set('api', 'iv', nil)
        Discourse::Config.set('api', 'salt', nil)
        Discourse::Config.set('api', 'encrypted_key', nil)
      end

      def skip_test_api_key_set
        Discourse::Config.set('credentials', 'encrypted_api_key', '12345')
        CLI::UI::Prompt.expects(:ask).with(api_key_question).never

        Discourse::Utils::ApiCredentials.call
      end

      def test_api_credentials_set
        Discourse::Config.set('api', 'iv', '/rWG62wumQw0Na7nZkg9Lw==')
        Discourse::Config.set('api', 'salt', '/rWG62wumQw0Na7nZkg9Lw==')
        Discourse::Config.set('api', 'encrypted_key',
                              'HQJ08bBSizNSv/SDHN9F4EZMH0eqEHzNabkc4SskIjw=')

        CLI::UI::Prompt.expects(:ask_password).never
        CLI::UI::Prompt.expects(:confirm).never

        Discourse::Utils::ApiCredentials.call
      end

      def test_api_credentials_not_set
        CLI::UI::Prompt.expects(:ask_password)
                       .with(password_prompt(false))
                       .returns('simplepass').once
        CLI::UI::Prompt.expects(:ask_password)
                       .with(password_confirm)
                       .returns('simplepass').once
        CLI::UI::Prompt.expects(:ask_password)
                       .with(api_key_prompt)
                       .returns(api_key).once
        CLI::UI::Prompt.expects(:confirm).with(api_key_confirm('0123'))
                       .returns(true).once

        Discourse::Utils::ApiCredentials.call

        unencoded_api_key = Discourse::Utils::ApiKey.api_key('simplepass')
        assert_equal api_key, unencoded_api_key
      end

      private

      def api_key
        '01234567' * 4
      end

      def password_prompt(mismatch)
        Discourse::Utils::AskPassword.prompt_text(Discourse::Utils::ApiCredentials.ask_password_question,
                                                  Discourse::Utils::ApiCredentials.mismatch_prompt,
                                                  mismatch:)
      end

      def password_confirm
        Discourse::Utils::ApiCredentials.ask_password_confirm
      end

      def api_key_prompt
        Discourse::Utils::ApiCredentials.ask_api_key_question
      end

      def api_key_confirm(key_start)
        Discourse::Utils::ApiCredentials.api_key_confirm(key_start)
      end
    end
  end
end
