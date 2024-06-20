# frozen_string_literal: true

require 'discourse/utils/config'

module Discourse
  module Commands
    class PublishNote < Discourse::Command
      def call(_args, _name)
        Discourse::Utils::Config.check_config
      end

      def self.help
        'Publishes a markdown file to Discourse'
      end
    end
  end
end
