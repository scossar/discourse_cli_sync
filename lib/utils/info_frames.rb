# frozen_string_literal: true

require_relative 'category_info'
require_relative 'vault_info'

module Discourse
  module Utils
    module InfoFrames
      def self.info(site, api_key)
        site_info_frame(site, api_key)
        vault_info_frame(site)
      end

      def self.site_info_frame(site, api_key)
        CLI::UI::Frame.open('Discourse info') do
          categories, category_names = Discourse::Utils::CategoryInfo.category_loader(site, api_key)
          [categories, category_names]
        end
      end

      def self.vault_info_frame(site)
        CLI::UI::Frame.open('Vault info') do
          Discourse::Utils::VaultInfo.directory_loader(site)
        end
      end
    end
  end
end
