# frozen_string_literal: true

module Discourse
  class Directory < ActiveRecord::Base
    has_many :notes, dependent: :destroy
    belongs_to :discourse_category, optional: true

    validates :path, presence: true, uniqueness: true
    validates :archetype, presence: true
  end
end
