# frozen_string_literal: true

module Discourse
  module Utils
    module PublishDirectoryFrame
      def self.publish(directories)
        publish_frame(directories)
      end

      def self.publish_frame(directories)
        puts "publishing #{directories}"
      end
    end
  end
end
