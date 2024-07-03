# frozen_string_literal: true

require_relative 'category_info'
require_relative 'vault_info'

module Discourse
  module Utils
    class InfoFrames
      class << self
        def call(discourse_site:, api_key:)
          @discourse_site = discourse_site
          @api_key = api_key
          site_info_frame
          vault_info_frame
        end

        private

        def site_info_frame
          CLI::UI::Frame.open('Discourse info') do
            categories, category_names = Discourse::Utils::CategoryInfo
                                         .category_loader(@discourse_site, @api_key)
            [categories, category_names]
          end
        end

        def vault_info_frame
          CLI::UI::Frame.open('Vault info') do
            Discourse::Utils::VaultInfo.directory_loader(@discourse_site)
          end
        end
      end
    end
  end
end
