# frozen_string_literal: true

module Discourse
  class Note < ActiveRecord::Base
    belongs_to :directory
    has_one :discourse_topic, dependent: :destroy
  end
end
