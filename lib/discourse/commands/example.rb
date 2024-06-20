require 'discourse'

module Discourse
  module Commands
    class Example < Discourse::Command
      def call(_args, _name)
        puts 'neato'

        return unless rand < 0.05

        raise(CLI::Kit::Abort, 'you got unlucky!')
      end

      def self.help
        "A dummy command.\nUsage: {{command:#{Discourse::TOOL_NAME} example}}"
      end
    end
  end
end
