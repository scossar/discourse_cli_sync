# frozen_string_literal: true

module Discourse
  class DiscourseCategory < ActiveRecord::Base
    has_many :discourse_topics
    has_many :directories
    belongs_to :discourse_site

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true
    validates :read_restricted, inclusion: { in: [true, false] }
    validates :discourse_site, presence: true

    def self.create_or_update(name:, slug:, read_restricted:, description:, discourse_id:,
                              discourse_site:)
      category = DiscourseCategory.find_by(name:, discourse_site:)
      if category
        category.update(name:, slug:, read_restricted:, description:, discourse_id:,
                        discourse_site:)
      else
        DiscourseCategory.create(name:, slug:, read_restricted:, description:, discourse_id:,
                                 discourse_site:)
      end
    end
  end
end
