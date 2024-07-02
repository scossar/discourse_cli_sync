# frozen_string_literal: true

require_relative '../../utils/discourse_config'
require_relative '../../utils/configure_host'

module Discourse
  module Commands
    class PublishDirectory < Discourse::Command
      def call(_args, _name)
        host = credential_frames
      end

      def self.help
        'Publishes a vault directory to Discourse'
      end

      def credential_frames
        CLI::UI::Frame.open('Discourse credentials') do
          host = Discourse::Utils::ConfigureHost.call
          puts "host: #{host}"
        end
      end
    end
  end
end
