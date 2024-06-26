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
        Discourse::Config.set('api', 'iv', nil)
        Discourse::Config.set('api', 'salt', nil)
        Discourse::Config.set('api', 'encrypted_key', nil)
      end

      def skip_test_api_key_set
        Discourse::Config.set('credentials', 'encrypted_api_key', '12345')
        CLI::UI::Prompt.expects(:ask).with(api_key_question).never

        Discourse::Utils::ApiCredentials.call
      end

      def api_credentials_set
        Discourse::Config.set('api', 'iv', '/rWG62wumQw0Na7nZkg9Lw==')
        Discourse::Config.set('api', 'salt', '/rWG62wumQw0Na7nZkg9Lw==')
        Discourse::Config.set('api', 'encrypted_key',
                              'HQJ08bBSizNSv/SDHN9F4EZMH0eqEHzNabkc4SskIjw=')

        CLI::UI::Prompt.expects(:ask_password).with(Discourse::Utils::ApiCredentials
          .ask_password_question).never
        CLI::UI::Prompt.expects(:confirm).with(Discourse::Utils::ApiCredentials
          .ask_password_confirm).never
        CLI::UI::Prompt.expects(:ask_password).with(Discourse::Utils::ApiCredentials
          .ask_api_key_question).never
        CLI::UI::Prompt.expects(:confirm).never

        Discourse::Utils::ApiCredentials.call
      end

      private

      def api_key
        '01234567' * 4
      end
    end
  end
end
