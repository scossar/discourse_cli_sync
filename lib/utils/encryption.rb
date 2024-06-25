# frozen_string_literal: true

require 'base64'
require 'openssl'

module Discourse
  module Utils
    module Encryption
      def self.encrypt(password, data)
        iv, salt, encrypted = encrypt_to_encoded(password, data)
        [encode_to_base64(iv), encode_to_base64(salt), encode_to_base64(encrypted)]
      end

      def self.decrypt(password, salt, initialization_vector, encrypted)
        salt = decode_from_base64(salt)
        iv = decode_from_base64(initialization_vector)
        encrypted = decode_from_base64(encrypted)

        decrypt_decoded(password, salt, iv, encrypted)
      end

      def self.generate_salt
        OpenSSL::Random.random_bytes(16)
      end

      def self.encrypt_to_encoded(password, data)
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        iv = cipher.random_iv
        digest = OpenSSL::Digest.new('SHA256')
        salt = generate_salt
        key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 20_000, cipher.key_len, digest)
        cipher.key = key
        encrypted = cipher.update(data) + cipher.final
        [iv, salt, encrypted]
      end

      def self.decrypt_decoded(password, salt, initialization_vector, encrypted)
        decipher = OpenSSL::Cipher.new('aes-256-cbc')
        decipher.decrypt
        decipher.iv = initialization_vector
        digest = OpenSSL::Digest.new('SHA256')
        key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 20_000, decipher.key_len, digest)
        decipher.key = key
        decipher.update(encrypted) + decipher.final
      end

      def self.encode_to_base64(data)
        encoded = Base64.encode64(data)
        encoded.encode('utf-8')
      end

      def self.decode_from_base64(data)
        Base64.decode64(data).force_encoding('ascii-8bit')
      end
    end
  end
end
