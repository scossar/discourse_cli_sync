# frozen_string_literal: true

module Discourse
  class DiscourseSite < ActiveRecord::Base
    validates :domain, presence: true
    validates :base_url, presence: true
  end
end
