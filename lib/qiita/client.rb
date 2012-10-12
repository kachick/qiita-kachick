require 'optionalargument'
require_relative 'connection'

module Qiita

  class Client

    ConstructorOption = OptionalArgument.define {
      opt :url_name, condition: AND(String, /./), aliases: [:name]
      opt :password, condition: AND(String, /./)
    }

    AuthenticateOption = OptionalArgument.define {
      opt :url_name, must: true, condition: AND(String, /./), aliases: [:name]
      opt :password, must: true, condition: AND(String, /./)
    }

    def initialize(options={})
      opts = ConstructorOption.parse options

      @url_name = opts.url_name
      @password = opts.password
      @token = nil
      @connection = nil
    end

    %w(url_name password token).each do |ivar|
      define_method ivar do
        val = instance_variable_get :"@#{ivar}"
        val && val.dup
      end

      define_method :"with_#{ivar}?" do
        !!val
      end
    end

    def rate_limit
      http.get '/rate_limit'
    end

    def auth(options)
      opts = AuthenticateOption.parse options
      json = http.post('/auth', opts.to_h)
      @token = json['token']
    end

    alias_method :authenticate, :auth
    alias_method :login, :auth

    # @todo validate params
    def post_item(params)
      http.post '/items', params
    end

    alias_method :post, :post_item

    # @todo validate params
    def update_item(uuid, params)
      http.put "/items/#{uuid}", params
    end

    alias_method :update, :update_item
    alias_method :modify, :update_item

    def delete_item(uuid)
      http.delete "/items/#{uuid}"
    end

    alias_method :delete, :delete_item

    # more deep than other getters 
    def item(uuid)
      http.get "/items/#{uuid}"
    end

    SearcherOption = OptionalArgument.define {
      opt :q, must: true, aliases: [:query], condition: String
      opt :stocked, default: false, condition: BOOLEAN?
    }

    def search_items(params)
      http.get "/search", SearcherOption.parse(params).to_h
    end

    alias_method :select, :search_items
    alias_method :find_all, :select

    def stock_item(uuid)
      http.put "/items/#{uuid}/stock"
    end

    alias_method :stock, :stock_item

    def unstock_item(uuid)
      http.delete "/items/#{uuid}/stock"
    end

    alias_method :unstock, :unstock_item

    # @group Around User

    def user_items(url_name=nil)
      url_name ? http.get("/users/#{url_name}/items") : my_items
    end

    alias_method :items_by_user, :user_items

    def my_items
      http.get '/items'
    end

    def user_stocks(url_name=nil)
      url_name ? http.get("/users/#{url_name}/stocks") : my_stocks
    end

    alias_method :stocks_by_user, :user_stocks

    def my_stocks
      http.get '/stocks'
    end

    def user(url_name)
      http.get "/users/#{url_name}"
    end

    # @endgroup

    # @group Around Tag

    def tag_items(tag)
      http.get "/tags/#{tag}/items"
    end

    alias_method :items_by_tag, :tag_items

    def tags
      http.get '/tags'
    end

    # @endgroup

    private

    def connection
      @connection ||= Connection.new
      @connection.token = @token
      @connection.open
      @connection
    end

    alias_method :http, :connection

  end

end
