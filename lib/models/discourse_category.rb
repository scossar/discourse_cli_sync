# frozen_string_literal: true

require_relative '../errors/errors'

module Discourse
  class DiscourseCategory < ActiveRecord::Base
    has_many :discourse_topics
    has_many :directories
    belongs_to :discourse_site

    validates :name, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :slug, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :read_restricted, inclusion: { in: [true, false] }
    validates :discourse_site, presence: true

    def self.create_or_update(params)
      name, slug, read_restricted, description, discourse_id, discourse_site =
        create_or_update_params(params)
      Discourse::Utils::Logger.debug("name: #{name}")

      begin
        category = DiscourseCategory.find_or_initialize_by(discourse_id:,
                                                           discourse_site:)
        category.assign_attributes(name:, slug:, read_restricted:,
                                   description:)
        raise Discourse::Errors::BaseError, 'Error saving DiscourseCategory' unless category.save
      rescue StandardError => e
        raise Discourse::Errors::BaseError, "Error saving DiscourseCategory: #{e.message}"
      end
    end

    def self.create_or_update_params(params)
      name = params[:name]
      slug = params[:slug]
      read_restricted = params[:read_restricted]
      description = params[:description]
      discourse_id = params[:discourse_id]
      discourse_site = params[:discourse_site]

      [name, slug, read_restricted, description, discourse_id, discourse_site]
    end
  end
end
