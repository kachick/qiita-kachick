require 'json'
require 'faraday'
require 'faraday_middleware'
require_relative '../faraday/response/raise_qiita_error'

module Qiita

  class Connection

    FARADAY_OPTIONS =  {
      url: ROOT_URL,
      ssl: { 
        verify: false
      }.freeze
    }.freeze

    if respond_to? :private_constant
      private_constant :FARADAY_OPTIONS
    end

    attr_writer :token

    def initialize
      @value = nil
      @token = nil
    end

    def connect
      @value ||= Faraday.new(FARADAY_OPTIONS) {|faraday|
        faraday.request :json
        faraday.adapter Faraday.default_adapter
        faraday.use Faraday::Response::RaiseQiitaError
        faraday.use FaradayMiddleware::Mashify
        faraday.use FaradayMiddleware::ParseJson
      }
    end

    alias_method :open, :connect

    def opened?
      !!@value
    end

    [:get, :delete, :post, :put].each do |http_action|
      define_method http_action do |path, params={}|
        path = "/api/v1#{path}"
        params = params_for_faraday.merge params
        response = @value.__send__(http_action) do |req|
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

    private

    def params_for_faraday
      {}.tap {|base|
        if @token
          base.update token: @token
        end
      }
    end

  end

  if respond_to? :private_constant
    private_constant :Connection
  end

end
