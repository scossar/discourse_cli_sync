# frozen_string_literal: true

module Discourse
  class DiscourseSite < ActiveRecord::Base
    has_many :notes

    validates :domain, presence: true
    validates :base_url, presence: true
  end
end
