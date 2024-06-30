# frozen_string_literal: true

module Discourse
  class DiscourseCategory < ActiveRecord::Base
    has_many :discourse_topics
    has_many :directories

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true
    validates :read_restricted, inclusion: { in: [true, false] }

    # TODO: if a category has been deleted on Discourse, it should be
    # deleted here with some kind of warning
    def self.create_or_update(name:, slug:, read_restricted:, description:)
      category = DiscourseCategory.find_by(name:)
      if category
        category.update(name:, slug:, read_restricted:, description:)
      else
        DiscourseCategory.create(name:, slug:, read_restricted:, description:)
      end
    end
  end
end
