# frozen_string_literal: true

module Discourse
  class Directory < ActiveRecord::Base
    has_many :notes
    belongs_to :discourse_site
    # TODO: it discourse_category should be optional, but not for now
    # belongs_to :discourse_category, optional: true
    belongs_to :discourse_category

    validates :path, presence: true, uniqueness: true
    validates :archetype, presence: true, inclusion: { in: %w[regular personal_message] }
    validates :discourse_site, presence: true
  end
end
