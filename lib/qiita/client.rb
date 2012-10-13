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

    PostOption = OptionalArgument.define {
      opt :title, condition: String
      opt :tags, condition: GENERICS(Hash)
      opt :body, condition: String
      opt :private, condition: false
      opt :gist, condition: BOOLEAN?
      opt :tweet, default: false, condition: BOOLEAN?
    }

    def post_item(params)
      params = PostOption.parse params
      http.post '/items', params.to_h
    end

    alias_method :post, :post_item

    UpdateOption = OptionalArgument.define {
      opt :title, condition: String
      opt :tags, condition: GENERICS(Hash)
      opt :body, condition: String
      opt :private, condition: false
    }

    def update_item(uuid, params)
      params = UpdateOption.parse params
      http.put "/items/#{uuid}", params.to_h
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

    # @yield [item]
    # @yieldreturn [self]
    # @return [Enumerator]
    def foreach(shallow_items)
      return to_enum(__callee__, shallow_items) unless block_given?

      shallow_items.each do |shallow|
        yield item(shallow.uuid)
      end
      self
    end

    SearcherOption = OptionalArgument.define {
      opt :q, aliases: [:query], condition: String
      opt :queries, condition: GENERICS(String)
      conflict :q, :queries
      opt :stocked, default: false, condition: BOOLEAN?
    }

    def search_items(params)
      params = SearcherOption.parse(params)
      hash = params.to_h
      hash[:q] = params.queries.join(' ') if params.with_queries?
      http.get "/search", hash
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

    def following_users(url_name)
      http.get "/users/#{url_name}/following_users"
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
