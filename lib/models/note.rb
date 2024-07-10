# frozen_string_literal: true

require_relative '../errors/errors'
require_relative '../utils/logger'

module Discourse
  class Note < ActiveRecord::Base
    # TODO: fix this
    belongs_to :directory, optional: true
    belongs_to :discourse_site

    validates :title, presence: true, uniqueness: { scope: :directory_id }
    validates :file_id, presence: true, uniqueness: { scope: :discourse_site }
    validates :local_only, inclusion: { in: [true, false] }
    validates :directory, presence: true
    validates :discourse_site, presence: true

    def self.create_or_update(note_args)
      title = note_args[:title]
      local_only = note_args[:local_only] || false
      topic_url = note_args[:topic_url]
      topic_id = note_args[:topic_id]
      post_id = note_args[:post_id]
      discourse_site = note_args[:discourse_site]
      directory = note_args[:directory]
      file_id = note_args[:file_id]
      discourse_site = note_args[:discourse_site]
      file_id = note_args[:file_id]

      Discourse::Utils::Logger.debug("title: #{title}, local_only: #{local_only}, topic_url: #{topic_url}, topic_id: #{topic_id}" \
                                     "post_id: #{post_id}, discourse_site_domain: #{discourse_site&.domain}, directory_path: #{directory&.path}, file_id: #{file_id}")

      note = Note.find_by(discourse_site:, file_id:)

      if note
        Note.update(title:, local_only:, topic_url:, topic_id:, post_id:, discourse_site:,
                    directory:, file_id:).tap do |response|
          raise Discourse::Errors::BaseError, 'unable to update note' unless response
        end
      else
        Note.create(title:, local_only:, topic_url:, topic_id:, post_id:, discourse_site:,
                    directory:, file_id:).tap do |note|
          raise Discourse::Errors::BaseError, 'unable to create note' unless note.persisted?
        end
      end
    rescue StandardError => e
      raise Discourse::Errors::BaseError, "Error saving Note: #{e.message}"
    end
  end
end
