# frozen_string_literal: true

require_relative '../errors/errors'

module Discourse
  class Note < ActiveRecord::Base
    validates :title, presence: true, uniqueness: true
    validates :file_id, presence: true, uniqueness: true
    validates :path, presence: true
    validates :full_path, presence: true, uniqueness: true
    validates :local_only, inclusion: { in: [true, false] }

    def self.create_note(params)
      title = params[:title]
      local_only = params[:local_only] || false
      file_id = params[:file_id]
      full_path = params[:full_path]
      path = params[:path]

      Note.create(title:, local_only:, file_id:, full_path:, path:).tap do |note|
        unless note.persisted?
          raise Discourse::Errors::BaseError,
                "Unable to create note for #{title}"
        end
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
