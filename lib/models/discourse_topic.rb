# frozen_string_literal: true

module Discourse
  class DiscourseTopic < ActiveRecord::Base
    belongs_to :note
    belongs_to :discourse_category, optional: true

    validates :url, presence: true, uniqueness: true
    validates :topic_id, presence: true, uniqueness: true
    validates :post_id, presence: true, uniqueness: true
    validates :archetype, presence: true, inclusion: { in: %w[regular private_message] }
  end
end
