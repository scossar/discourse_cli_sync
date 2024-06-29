# frozen_string_literal: true

module Discourse
  class Note < ActiveRecord::Base
    belongs_to :directory, optional: true
    belongs_to :discourse_category, optional: true

    validates :title, presence: true, uniqueness: { scope: :directory_id }
    validates :local_only, inclusion: { in: [true, false] }
    validates :topic_url, uniqueness: true
    validates :topic_id, uniqueness: true
    validates :post_id, uniqueness: true
  end
end
