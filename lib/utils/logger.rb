# frozen_string_literal: true

module Discourse
  module Utils
    module Logger
      def self.debug(msg)
        logger = CLI::Kit::Logger.new(debug_log_file: '/tmp/obsidian_debug.log')
        logger.debug(msg)
      end
    end
  end
end
