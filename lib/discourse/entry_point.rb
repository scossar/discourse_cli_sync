require 'discourse'

module Discourse
  module EntryPoint
    def self.call(args)
      cmd, command_name, args = Discourse::Resolver.call(args)
      Discourse::Executor.call(cmd, command_name, args)
    end
  end
end
