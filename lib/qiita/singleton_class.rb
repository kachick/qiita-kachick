module Qiita

  class << self

    def login(options)
      Client.new.tap {|client|
        client.auth options
      }
    end

    def client(options, &block)
      client = login options
      client.instance_exec(&block)
    end

  end

end
