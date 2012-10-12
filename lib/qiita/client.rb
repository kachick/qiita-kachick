require 'faraday'
require 'faraday_middleware'
require_relative '../faraday/response/raise_qiita_error'
require 'json'
require_relative 'error'
require_relative 'client/items'
require_relative 'client/tags'
require_relative 'client/users'

module Qiita

  class Client

    ROOT_URL = 'https://qiita.com/'.freeze
    FARADAY_OPTIONS =  {
      url: ROOT_URL,
      ssl: { 
        verify: false
      }.freeze
    }.freeze

    CONSTRUCT_KEYS = [:url_name, :password, :token].freeze

    include Items
    include Tags
    include Users

    attr_accessor(*CONSTRUCT_KEYS)

    def initialize(args)
      CONSTRUCT_KEYS.each do |key|
        __send__(:"#{key}=", args[key])
      end

      if token.nil? && url_name && password
        login
      end
    end

    def rate_limit(params={})
      get '/rate_limit', params
    end

    private

    def login
      @token = json['token']
    end

    def json
      post '/auth', url_name: @url_name, password: @password
    end

    def connection
      @connection ||= _connect
    end

    def _connect
      Faraday.new(FARADAY_OPTIONS) {|faraday|
        faraday.request :json
        faraday.adapter Faraday.default_adapter
        faraday.use Faraday::Response::RaiseQiitaError
        faraday.use FaradayMiddleware::Mashify
        faraday.use FaradayMiddleware::ParseJson
      }
    end

    def get(path, params={})
      request :get, path, params
    end

    def delete(path, params={})
      request :delete, path, params
    end

    def post(path, params={})
      request :post, path, params
    end

    def put(path, params={})
      request :put, path, params
    end

    def request(method, path, params)
      path = "/api/v1/#{path}"
      params.merge!(:token => token) if token

      response = connection.__send__(method) do |req|
        req.headers['Content-Type'] = 'application/json'
        case method
        when :get, :delete
          req.url path, params
        when :post, :put
          req.path = path
          req.body = params.to_json unless params.empty?
        end
      end

      response.body
    end

  end

end
