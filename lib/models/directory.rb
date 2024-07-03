# frozen_string_literal: true

module Discourse
  class Directory < ActiveRecord::Base
    has_many :notes
    belongs_to :discourse_site
    belongs_to :discourse_category, optional: true

    validates :path, presence: true, uniqueness: true
    validates :discourse_site, presence: true
  end
end
