# frozen_string_literal: true

require_relative 'api_credentials'
require_relative 'api_key'
require_relative 'ask_password'
require_relative 'configure_host'

module Discourse
  module Utils
    module CredentialFrame
      def self.call
        CLI::UI::Frame.open('Discourse credentials') do
          discourse_site = Discourse::Utils::ConfigureHost.call
          password = Discourse::Utils::ApiCredentials.call(discourse_site)
          password ||= Discourse::Utils::AskPassword.ask_password('Your API key password')
          api_key = Discourse::Utils::ApiKey.api_key(discourse_site, password)
          [discourse_site, api_key]
        end
      end
    end
  end
end
