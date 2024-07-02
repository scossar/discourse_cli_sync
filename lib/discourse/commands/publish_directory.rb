# frozen_string_literal: true

require_relative '../../utils/api_credentials'
require_relative '../../utils/api_key'
require_relative '../../utils/ask_password'
require_relative '../../utils/configure_host'

module Discourse
  module Commands
    class PublishDirectory < Discourse::Command
      def call(_args, _name)
        discourse_site, api_key = credential_frames
      end

      def self.help
        'Publishes a vault directory to Discourse'
      end

      def credential_frames
        CLI::UI::Frame.open('Discourse credentials') do
          discourse_site = Discourse::Utils::ConfigureHost.call
          password = Discourse::Utils::ApiCredentials.call(discourse_site)
          password ||= Discourse::Utils::AskPassword.ask_password('Your API key password')
          api_key = Discourse::Utils::ApiKey.api_key(discourse_site, password)
          puts "api key: #{api_key}"
          [discourse_site, api_key]
        end
      end
    end
  end
end
