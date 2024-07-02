# frozen_string_literal: true

require_relative '../../utils/api_credentials'
require_relative '../../utils/configure_host'

module Discourse
  module Commands
    class PublishDirectory < Discourse::Command
      def call(_args, _name)
        domain, api_key = credential_frames
      end

      def self.help
        'Publishes a vault directory to Discourse'
      end

      def credential_frames
        CLI::UI::Frame.open('Discourse credentials') do
          discourse_site = Discourse::Utils::ConfigureHost.call
          password = Discourse::Utils::ApiCredentials.call(discourse_site)
          puts "password: #{password}"
        end
      end
    end
  end
end
