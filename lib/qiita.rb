require_relative 'qiita/client'
require_relative 'qiita/version'

module Qiita

  class << self

    def new(options={})
      Qiita::Client.new options
    end

    # Delegate to Qiita::Client.new
    def method_missing(method, *args, &block)
      return super unless new.respond_to?(method)
      new.__send__(method, *args, &block)
    end

  end

end
