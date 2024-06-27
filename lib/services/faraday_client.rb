# frozen_string_literal: true

require_relative '../errors/errors'
module Discourse
  class FaradayClient
    DEFAULT_TIMEOUT = 30

    def initialize(api_key)
      @api_username = Discourse::Config.get('credentials', 'discourse_username')
      @base_url = Discourse::Config.get('discourse_site', 'base_url')
      @api_key = api_key
    end

    def connection_options
      @connection_options ||= {
        url: @base_url,
        request: {
          timeout: DEFAULT_TIMEOUT
        },
        headers: {
          accept: 'application/json',
          user_agent: 'ObsidianDiscourse'
        }
      }
    end

    def get(path, params = {})
      response = request(:get, path, params)
      response.body
    end

    def post(path, params = {})
      response = request(:post, path, params)
      response.body
    end

    def put(path, params = {})
      response = request(:put, path, params)
      response.body
    end

    private

    def connection
      @connection ||=
        Faraday.new connection_options do |conn|
          conn.request :multipart
          conn.request :url_encoded
          conn.response :follow_redirects, limit: 5
          conn.response :json, content_type: 'application/json'
          conn.adapter Faraday.default_adapter
          conn.headers['Api-Key'] = @api_key
          conn.headers['Api-Username'] = @api_username
        end
    end

    def request(method, path, params = {})
      params = params.to_h if !params.is_a?(Hash) && (params.respond_to? :to_h)
      response = connection.send(method.to_sym, path, params)
      handle_error(response)
      response.env
    rescue Faraday::ConnectionFailed => e
      rescue_error(e, 'connection_failed')
    rescue Faraday::TimeoutError => e
      rescue_error(e, 'timeout')
    rescue Faraday::SSLError => e
      rescue_error(e, 'ssl_error')
    rescue Faraday::Error => e
      rescue_error(e, 'unknown_error')
    ensure
      sleep 1
    end

    def handle_error(response)
      case response.status
      when 403
        raise_unauthenticated_error(response)
      when 404, 410
        raise_not_found_error(response)
      when 422
        raise_unprocessable_entity(response)
      when 429
        raise_too_many_requests(response)
      when 500...600
        raise_server_error(response)
      end
    end

    def rescue_error(error, error_type)
      raise Discourse::Errors::BaseError, "#{error_type}: #{error.message}"
    end

    def raise_unauthenticated_error(response)
      raise Discourse::Errors::BaseError,
            "#{response.status}: You do not have permission to access that resource"
    end

    def raise_not_found_error(response)
      raise Discourse::Errors::BaseError,
            "#{response.status}: Resource not found"
    end

    def raise_unprocessable_entity(response)
      raise Discourse::Errors::BaseError,
            "#{response.status}: Unprocessable entity"
    end

    def raise_too_many_requests(response)
      raise Discourse::Errors::BaseError,
            "#{response.status}: Too many requests"
    end

    def raise_server_error(response)
      raise Discourse::Errors::BaseError,
            "#{response.status}: Server error"
    end
  end
end
