# frozen_string_literal: true

require_relative 'ui_utils'

module Discourse
  module Utils
    module PublishDirectoryFrame
      def self.publish(root_directory:, directories:)
        publish_frame(root_directory, directories)
      end

      def self.publish_frame(root_directory, _directories)
        short_path = Discourse::Utils::Ui.fancy_path(root_directory.path)
        CLI::UI::Frame.open("Publishing notes from #{short_path}") do
          'publish directories here'
        end
      end
    end
  end
end
