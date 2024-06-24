# frozen_string_literal: true

require 'openssl'

module Discourse
  module Utils
    class ApiCredentials
      class << self
        KEY_FILE = 'key.key'

        def call
          key_data = generate_key
          save_key(key_data)
          api_key = '1234'
          encrypted_api_key = encrypt_api_key(api_key, key_data)
          puts "encrypted: #{encrypted_api_key}"
          decrypted_api_key = decrypt_api_key(encrypted_api_key, key_data)
          puts "decrypted: #{decrypted_api_key}"
        end

        private

        def api_key
          encrypted_key = Discourse::Config.get('credentials', 'encrypted_api_key')

          unless encrypted_key
            loop do
              encrypted_key = CLI::UI::Prompt.ask_password('Enter your Discourse API key')
              confirm = CLI::UI::Prompt.confirm('Is that correct?')

              break if confirm
            end
          end
          # call some function that encrypts the key

          Discourse::Config.set('credentials', 'encrypted_api_key', encrypted_key)
        end

        def generate_key
          cipher = OpenSSL::Cipher.new('aes-256-cbc')
          cipher.encrypt
          key = cipher.random_key
          iv = cipher.random_iv
          { key:, iv: }
        end

        def save_key(key_data)
          File.open(KEY_FILE, 'wb') do |file|
            file.write(key_data[:key])
            file.write(key_data[:iv])
            file
          end
        end

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
      end
    end
  end
end
