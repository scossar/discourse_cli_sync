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
        discourse_site, api_key = Discourse::Utils::CredentialFrame.credentials_for_site
        Discourse::Utils::InfoFrames.info(discourse_site, api_key)
        root_directory, use_subdirectories = Discourse::Utils::DirectorySelectorFrame
                                             .select(discourse_site)
        directories = Discourse::Utils::CategorySelectorFrame.select(root_directory,
                                                                     use_subdirectories,
                                                                     discourse_site)
        Discourse::Utils::DirectoryPublisher.call(root_directory:, directories:)
      end

      def self.help
        'Publishes a vault directory to Discourse'
      end
    end
  end
end
