# frozen_string_literal: true

require_relative 'encryption'

module Discourse
  module Utils
    module ApiKey
      def self.api_key(discourse_site, password)
        salt = discourse_site.salt
        iv = discourse_site.iv
        encrypted_api_key = discourse_site.encrypted_api_key
        Encryption.decrypt(password, salt, iv, encrypted_api_key)
      end
    end
  end
end
