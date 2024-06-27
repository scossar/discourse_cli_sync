# frozen_string_literal: true

require_relative '../../utils/api_credentials'
require_relative '../../utils/api_key'
require_relative '../../utils/ask_password'
require_relative '../../utils/discourse_config'

module Discourse
  module Commands
    class PublishNote < Discourse::Command
      def call(_args, _name)
        password, api_key = credential_frames
        puts "password: #{password}, api_key: #{api_key}"
      end

      def self.help
        'Publishes a markdown file to Discourse'
      end

      def credential_frames
        CLI::UI::Frame.open('Discourse credentials') do
          Discourse::Utils::DiscourseConfig.call
          # TODO: return the password from ApiCredentials.call.
          # if it's not null, don't ask again in the command
          Discourse::Utils::ApiCredentials.call
          password = Discourse::Utils::AskPassword.ask_password('Your API key password')
          api_key = Discourse::Utils::ApiKey.api_key(password)
          [password, api_key]
        end
      end
    end
  end
end
