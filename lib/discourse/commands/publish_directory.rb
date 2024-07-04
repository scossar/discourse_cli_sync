# frozen_string_literal: true

require_relative '../../utils/category_selector_frame'
require_relative '../../utils/credential_frame'
require_relative '../../utils/directory_selector_frame'
require_relative '../../utils/info_frames'
require_relative '../../utils/directory_publisher'

module Discourse
  module Commands
    class PublishDirectory < Discourse::Command
      def call(_args, _name)
        discourse_site, api_key = Discourse::Utils::CredentialFrame.call
        Discourse::Utils::InfoFrames.call(discourse_site:, api_key:)
        root_directory, use_subdirectories = Discourse::Utils::DirectorySelectorFrame
                                             .call(discourse_site:)
        directories = Discourse::Utils::CategorySelectorFrame.call(directory: root_directory,
                                                                   use_subdirectories:,
                                                                   api_key:,
                                                                   discourse_site:)
        Discourse::Utils::DirectoryPublisher.call(root_directory:, directories:, api_key:,
                                                  discourse_site:)
      end

      def self.help
        'Publishes a vault directory to Discourse'
      end
    end
  end
end
