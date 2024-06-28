# frozen_string_literal: true

module Discourse
  class Note < ActiveRecord::Base
    belongs_to :directory
    has_many :discourse_topics

    validates :title, presence: true, uniqueness: { scope: :directory_id }
    validates :local_only, inclusion: { in: [true, false] }
  end
end
