# frozen_string_literal: true

require 'active_record'

module Discourse
  class Directory < ActiveRecord::Base
    has_many :notes
    belongs_to :discourse_category, optional: true

    validates :path, presence: true, uniqueness: true
    validates :archetype, presence: true, inclusion: { in: %w[regular personal_message] }
  end
end
