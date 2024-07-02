# frozen_string_literal: true

require_relative '../../utils/credential_frame'
require_relative '../../utils/info_frames'

module Discourse
  module Commands
    class PublishDirectory < Discourse::Command
      def call(_args, _name)
        discourse_site, api_key = Discourse::Utils::CredentialFrame.credentials_for_site
        Discourse::Utils::InfoFrames.info(discourse_site, api_key)
      end

      def self.help
        'Publishes a vault directory to Discourse'
      end
    end
  end
end
