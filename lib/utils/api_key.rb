# frozen_string_literal: true

require_relative 'api_credentials'
require_relative 'encryption'

module Discourse
  module Utils
    module ApiKey
      def self.api_key(host, password)
        iv, salt, encrypted_key = ApiCredentials.credentials(host)
        Encryption.decrypt(password, salt, iv, encrypted_key)
      end
    end
  end
end
