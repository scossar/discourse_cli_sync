# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'
require 'mime-types'

require_relative 'faraday_client'

module Discourse
  class DiscourseRequest
    def initialize
      @faraday_client = FaradayClient.new
    end
  end
end
