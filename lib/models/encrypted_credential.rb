# frozen_string_literal: true

module Discourse
  class EncryptedCredential < ActiveRecord::Base
    validates :host, presence: true, uniqueness: true
    validates :iv, presence: true
    validates :salt, presence: true
    validates :encrypted_api_key, presence: true
  end
end
