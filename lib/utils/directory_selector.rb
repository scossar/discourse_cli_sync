# frozen_string_literal: true

require_relative '../models/directory'
require_relative 'ui_utils'

module Discourse
  module Utils
    module DirectorySelector
      def self.select(site)
        select_dir(site)
      end

      def self.select_dir(site); end
    end
  end
end
