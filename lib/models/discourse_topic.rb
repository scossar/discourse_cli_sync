# frozen_string_literal: true

module Discourse
  class DiscourseTopic < ActiveRecord::Base
    belongs_to :note
    has_one :directory, through: :note
    has_one :discourse_category, through: :directory

    validates :discourse_url, presence: true, uniqueness: true
    validates :discourse_id, presence: true, uniqueness: true
    validates :discourse_post_id, presence: true, uniqueness: true
  end
end
