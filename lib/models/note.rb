# frozen_string_literal: true

module Discourse
  class Note < ActiveRecord::Base
    belongs_to :directory
    belongs_to :discourse_site

    validates :title, presence: true, uniqueness: { scope: :directory_id }
    validates :file_id, presence: true, uniqueness: { scope: :discourse_site }
    validates :local_only, inclusion: { in: [true, false] }
    validates :directory, presence: true
    validates :discourse_site, presence: true
  end
end
