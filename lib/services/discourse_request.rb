# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'
require 'mime-types'

require_relative 'faraday_client'

module Discourse
  class DiscourseRequest
    def initialize(site, api_key)
      @faraday_client = FaradayClient.new(site, api_key)
    end

    def create_topic(title:, markdown:, category:)
      params = { title:, raw: markdown, category:, skip_validations: true }
      @faraday_client.post('/posts.json', params)
    end

    def update_topic(topic_id:, category_id:)
      path = "/t/-/#{topic_id}.json"
      params = { category_id: }
      @faraday_client.put(path, params)
    end

    def update_post(markdown:, post_id:)
      params = { post: { raw: markdown, skip_validations: true } }
      @faraday_client.put("/posts/#{post_id}.json", params)
    end

    def upload_file(file_path)
      file_name = File.basename(file_path)
      mime_type = MIME::Types.type_for(file_name).first.to_s
      file = Faraday::UploadIO.new(file_path, mime_type)
      params = { file:, synchronous: true, type: 'composer' }
      @faraday_client.post('/uploads.json', params)
    end

    def site_info
      @faraday_client.get('/site.json')
    end
  end
end
