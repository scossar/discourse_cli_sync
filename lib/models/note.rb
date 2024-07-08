# frozen_string_literal: true

module Discourse
  class Note < ActiveRecord::Base
    belongs_to :directory
    belongs_to :discourse_site

    validates :title, presence: true, uniqueness: { scope: :directory_id }
    validates :local_only, inclusion: { in: [true, false] }
    validates :topic_url, uniqueness: { scope: :discourse_site_id }, allow_nil: true
    validates :topic_id, uniqueness: { scope: :discourse_site_id }, allow_nil: true
    validates :post_id, uniqueness: { scope: :discourse_site_id }, allow_nil: true
    validates :directory, presence: true
    validates :discourse_site, presence: true
  end
end
