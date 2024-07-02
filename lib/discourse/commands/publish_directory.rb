# frozen_string_literal: true

require_relative '../../utils/credential_frame'
require_relative '../../utils/directory_selector_frame'
require_relative '../../utils/info_frames'

module Discourse
  module Commands
    class PublishDirectory < Discourse::Command
      def call(_args, _name)
        discourse_site, api_key = Discourse::Utils::CredentialFrame.credentials_for_site
        Discourse::Utils::InfoFrames.info(discourse_site, api_key)
        directory, subdirectories = Discourse::Utils::DirectorySelectorFrame
                                    .select(discourse_site)
        puts "directory: #{directory}, subdirectories: #{subdirectories}"
      end

      def self.help
        'Publishes a vault directory to Discourse'
      end
    end
  end
end
