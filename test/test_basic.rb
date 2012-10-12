require 'declare/autorun'

$VERBOSE = true

require_relative '../lib/qiita'

The Qiita::Client.new do |client|

  The client do
    is_a Qiita::Client
  end

  The client.token do
    equal nil
  end

  The client.rate_limit do |mash|
    is_a Hashie::Mash

    The mash.limit do
      is 150
    end

    The mash.remaining do
      is_a Fixnum
      ok it <= mash.limit
    end
  end

end

