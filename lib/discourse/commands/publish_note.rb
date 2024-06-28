# frozen_string_literal: true

require_relative '../../utils/api_credentials'
require_relative '../../utils/api_key'
require_relative '../../utils/ask_password'
require_relative '../../utils/discourse_config'

module Discourse
  module Commands
    class PublishNote < Discourse::Command
      def call(_args, _name)
        credential_frames
      end

      def self.help
        'Publishes a markdown file to Discourse'
      end

      def credential_frames
        CLI::UI::Frame.open('Discourse credentials') do
          host = Discourse::Utils::DiscourseConfig.call
          password = Discourse::Utils::ApiCredentials.call(host)
          password ||= Discourse::Utils::AskPassword.ask_password('Your API key password')
          api_key = Discourse::Utils::ApiKey.api_key(host, password)
          puts "API KEY: #{api_key}"
          [host, password, api_key]
        end
      end
    end
  end
end
