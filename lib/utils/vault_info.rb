# frozen_string_literal: true

require_relative '../models/directory'
require_relative '../utils/ui_utils'

module Discourse
  module Utils
    class VaultInfo
      class << self
        def call(discourse_site)
          @discourse_site = discourse_site
          directory_info
        end

        private

        def directory_info
          directories = all_directories
          directories.each do |path|
            short_path = Discourse::Utils::Ui.fancy_path(path)
            CLI::UI::Frame.open("{{blue:#{short_path}}}") do
              find_or_create_directory(path)
            end
          end
        end

        def find_or_create_directory(path)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.failure_debrief do |_title, exception|
            puts CLI::UI.fmt "  #{exception}"
          end

          spin_group.add('Updating Directories') do |spinner|
            Discourse::Directory.create_or_update(path:, discourse_site: @discourse_site)
            short_path = Discourse::Utils::Ui.fancy_path(path)
            spinner.update_title("Updated database entry for {{blue:#{short_path}}}")
          end

          spin_group.wait
        end

        def all_directories
          vault_directory = @discourse_site.vault_directory
          root_dir = File.expand_path(vault_directory)
          dirs = Dir.glob(File.join(root_dir, '**', '*/')).map do |dir|
            normalize_path(dir)
          end
          dirs << normalize_path(root_dir)
        end

        def normalize_path(path)
          path.chomp('/')
        end
      end
    end
  end
end
