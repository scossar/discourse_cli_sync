# frozen_string_literal: true

require 'discourse'

module Discourse
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(default: 'help')

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(-> { const_get(const) }, cmd)
    end

    register :PublishDirectory, 'publish_directory', 'discourse/commands/publish_directory'
    register :SyncFiles, 'sync_files', 'discourse/commands/sync_files'
    register :Help, 'help', 'discourse/commands/help'
  end
end
