# frozen_string_literal: true

module Discourse
  class FaradayClient
    DEFAULT_TIMEOUT = 30

    def initialize(api_key)
      @api_username = Discourse::Config.get('credentials', 'discourse_username')
      @base_url = Discourse::Config.get('discourse_site', 'base_url')
      @api_key = api_key
    end
  end
end
