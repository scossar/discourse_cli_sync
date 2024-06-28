# frozen_string_literal: true

require 'active_record'

module Discourse
  class DiscourseCategory < ActiveRecord::Base
    has_many :discourse_topics
    has_many :directories

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true
    validates :read_restricted, inclusion: { in: [true, false] }
  end
end
