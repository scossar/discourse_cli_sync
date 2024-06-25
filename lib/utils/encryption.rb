# frozen_string_literal: true

require 'digest'
require 'openssl'

module Discourse
  module Utils
    module Encryption
      def self.cipher_key_from_password(password)
        Digest::SHA256.digest(password)
      end

      def self.encrypt_api_key(api_key, cipher_key)
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        cipher.key = cipher_key
        iv = cipher.random_iv
        encrypted_key = cipher.update(api_key) + cipher.final
        [encrypted_key, iv]
      end

      def self.decrypt_api_key(encrypted_key, initialization_vector, decipher_key)
        decipher = OpenSSL::Cipher.new('aes-256-cbc')
        decipher.decrypt
        decipher.key = decipher_key
        decipher.iv = initialization_vector
        decipher.update(encrypted_key) + decipher.final
      end
    end
  end
end
