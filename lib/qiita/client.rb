require 'faraday'
require 'faraday_middleware'
require_relative '../faraday/response/raise_qiita_error'
require 'json'
require 'optionalargument'
require_relative 'error'
require_relative 'client/items'
require_relative 'client/tags'
require_relative 'client/users'

module Qiita

  class Client

    FARADAY_OPTIONS =  {
      url: ROOT_URL,
      ssl: { 
        verify: false
      }.freeze
    }.freeze

    if respond_to? :private_constant
      private_constant :FARADAY_OPTIONS
    end

    include Items
    include Tags
    include Users

    ConstructorOption = OptionalArgument.define {
      opt :api_name, condition: AND(String, /./), aliases: [:name, :url_name]
      opt :password, condition: AND(String, /./)
      opt :token, condition: AND(String, /\A\w{20,}\z/)
      opt :json, condition: JSON
      opt :connection, condition: Faraday
    }

    def initialize(options={})
      opts = ConstructorOption.parse options

      @api_name = opts.api_name
      @password = opts.password
      @token = opts.token
      @json = opts.json
      @connection = opts.connection
    end

    def api_name
      @api_name && @api_name.dup
    end

    def rate_limit(params={})
      get '/rate_limit', params
    end

    def token
      @token ||= json['token']
    end

    def json
      @json ||= _login
    end

    def login
      raise 'already logined' if @json

      _login
    end

    def with_token?
      !!@token
    end

    private

    # @return [JSON]
    def _login
      post '/auth', params_for_login
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

    def params_for_login
      {api_name: @api_name, password: @password}
    end

    def params_for_faraday
      params_for_login.tap {|base|
        base.update token: token if with_token?
      }
    end

    %w(get delete post put).each do |http_action|
      define_method http_action do |path, params={}|
        path = "/api/v1/#{path}"
        params = params_for_faraday.merge params
        response = connection.__send__(http_action) do |req|
          req.headers['Content-Type'] = 'application/json'
          case http_action
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

end
