# frozen_string_literal: true

require_relative '../errors/errors'

module Discourse
  class Note < ActiveRecord::Base
    belongs_to :directory
    belongs_to :discourse_site

    validates :title, presence: true, uniqueness: { scope: :directory_id }
    validates :file_id, presence: true, uniqueness: { scope: :discourse_site }
    validates :local_only, inclusion: { in: [true, false] }
    validates :directory, presence: true
    validates :discourse_site, presence: true

    def self.create(params)
      title = params[:title]
      local_only = params[:local_only] || false
      topic_url = params[:topic_url]
      topic_id = params[:topic_id]
      post_id = params[:post_id]
      discourse_site = params[:discourse_site]
      directory = params[:directory]
      file_id = params[:file_id]

      Note.create(title:, local_only:, topic_url:, topic_id:, post_id:, discourse_site:,
                  directory:, file_id:).tap do |result|
        raise Discourse::Errors::BaseError, 'Unable to create Note' unless result.persisted?
      end
    rescue StandardError => e
      raise Discourse::Errors::BaseError, "Error creating Note: #{e.message}"
    end

    def self.update(note, params = {})
      title = params[:title]
      local_only = params[:local_only] || false
      topic_url = params[:topic_url]
      topic_id = params[:topic_id]
      post_id = params[:post_id]
      discourse_site = params[:discourse_site]
      directory = params[:directory]
      file_id = params[:file_id]

      note.update(title:, local_only:, topic_url:, topic_id:, post_id:, discourse_site:,
                  directory:, file_id:).tap do |result|
        raise Discourse::Errors::BaseError, 'Error updating Note' unless result
      end
    rescue StandardError => e
      rails Discourse::Errors::BaseError, "Error updating Note: #{e.message}"
    end
  end
end
