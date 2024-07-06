# frozen_string_literal: true

require_relative '../errors/errors'

module Discourse
  class Directory < ActiveRecord::Base
    has_many :notes
    belongs_to :discourse_site
    belongs_to :discourse_category, optional: true

    validates :path, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :discourse_site, presence: true

    def self.create_or_update(path:, discourse_site:)
      directory = Directory.find_or_initialize_by(path:, discourse_site:)
      raise Discourse::Errors::BaseError, 'Error saving Directory' unless directory.save
    rescue StandardError => e
      raise Discourse::Errors::BaseError, "Error saving Directory: #{e.message}"
    end
  end
end
