# frozen_string_literal: true

require_relative '../errors/errors'

module Discourse
  class Note < ActiveRecord::Base
    validates :title, presence: true, uniqueness: { scope: :directory_id }
    validates :file_id, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :full_path, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :local_only, inclusion: { in: [true, false] }

    def self.create_note(params)
      title = params[:title]
      local_only = params[:local_only] || false
      file_id = params[:file_id]
      full_path = params[:full_path]

      Note.create(title:, local_only:, file_id:, full_path:).tap do |note|
        raise Discourse::Errors::BaseError, 'Unable to create Note' unless note.persisted?
      end
    rescue StandardError => e
      raise Discourse::Errors::BaseError, "Error creating Note: #{e.message}"
    end

    def self.update_note(note, params = {})
      note.update(params).tap do |result|
        raise Discourse::Errors::BaseError, 'Error updating Note' unless result
      end
    rescue StandardError => e
      raise Discourse::Errors::BaseError, "Error updating Note: #{e.message}"
    end
  end
end
