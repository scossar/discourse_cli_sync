# frozen_string_literal: true

require 'base64'
require 'openssl'

module Discourse
  module Utils
    module Encrypt
      KEY_FILE = 'key.key'

      def encrypt_api_key(api_key, key_data)
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        cipher.key = key_data[:key]
        cipher.iv = key_data[:iv]
        cipher.update(api_key) + cipher.final
      end

      def decrypt_api_key(encrypted_api_key, key_data)
        decypher = OpenSSL::Cipher.new('aes-256-cbc')
        decypher.decrypt
        decypher.key = key_data[:key]
        decypher.iv = key_data[:iv]
        decypher.update(encrypted_api_key) + decypher.final
      end

      def generate_salt(length = 16)
        OpenSSL::Random.random_bytes(length)
      end

      def derive_key_from_password(password, salt, iterations = 10_000, key_length = 32)
        OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, key_length,
                                   OpenSSL::Digest.new('SHA256'))
      end

      def generate_key
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        key = cipher.random_key
        iv = cipher.random_iv
        { key:, iv: }
      end

      def save_key(encrypted_key, initialization_vector, salt)
        File.open(KEY_FILE, 'wb') do |file|
          file.write(salt) # Save the salt first
          file.write(initialization_vector) # Save the IV next
          file.write(encrypted_key) # Save the encrypted key
          file
        end
      end

      def encrypt_key(key, password)
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        salt = generate_salt
        derived_key = derive_key_from_password(password, salt)
        cipher.key = derived_key
        iv = cipher.random_iv
        encrypted_key = cipher.update(key) + cipher.final
        save_key(encrypted_key, iv, salt)
        iv
      end

      def decrypt_key(encrypted_key, initialization_vector, salt, password)
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.decrypt
        derived_key = derive_key_from_password(password, salt)
        cipher.key = derived_key
        cipher.iv = initialization_vector
        cipher.update(encrypted_key) + cipher.final
      end
    end
  end
end
