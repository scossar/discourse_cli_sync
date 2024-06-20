require 'discourse'

module Discourse
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(default: 'help')

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(->() { const_get(const) }, cmd)
    end

    register :Example, 'example', 'discourse/commands/example'
    register :Help,    'help',    'discourse/commands/help'
  end
end
