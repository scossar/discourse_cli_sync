# frozen_string_literal: true

require 'discourse'

module Discourse
  module Commands
    class Help < Discourse::Command
      def call(_args, _name)
        puts CLI::UI.fmt('{{bold:Available commands}}')
        puts ''

        Discourse::Commands::Registry.resolved_commands.each do |name, klass|
          next if name == 'help'

          puts CLI::UI.fmt("{{command:#{Discourse::TOOL_NAME} #{name}}}")
          if (help = klass.help)
            puts CLI::UI.fmt(help)
          end
          puts ''
        end
      end
    end
  end
end
