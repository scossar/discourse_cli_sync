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
          CLI::UI::Frame.open('Pulling in Discourse site data') do
            Discourse::Utils::CategoryInfo.call(discourse_site: @discourse_site, api_key: @api_key)
          end
        end

        def vault_info_frame
          CLI::UI::Frame.open('Syncing with local vault directories') do
            Discourse::Utils::VaultInfo.call(@discourse_site)
          end
        end
      end
    end
  end
end
