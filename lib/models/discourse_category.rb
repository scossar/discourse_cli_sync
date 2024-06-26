# frozen_string_literal: true

module Discourse
  class DiscourseCategory < ActiveRecord::Base
    has_many :directories

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true
    validates :discourse_id, presence: true, uniqueness: true
  end
end
