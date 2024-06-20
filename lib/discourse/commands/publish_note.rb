# frozen_string_literal: true

require_relative '../../utils/discourse_config'

module Discourse
  module Commands
    class PublishNote < Discourse::Command
      def call(_args, _name)
        Discourse::Utils::DiscourseConfig.call
      end

      def self.help
        'Publishes a markdown file to Discourse'
      end
    end
  end
end
