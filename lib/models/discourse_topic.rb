# frozen_string_literal: true

module Discourse
  class DiscourseTopic < ActiveRecord::Base
    belongs_to :discourse_site
    belongs_to :directory
    belongs_to :note

    validates :topic_id, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :topic_url, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :topic_id, presence: true, uniqueness: { scope: :discourse_site_id }
    validates :note, presence: true, uniqueness: { scope: :discourse_site_id }
  end
end
