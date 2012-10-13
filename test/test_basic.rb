require 'declare/autorun'

$VERBOSE = true

require_relative '../lib/qiita'

The Qiita::Client.new do |client|

  is_a Qiita::Client

  The client.token do
    equal nil
  end

  The client.rate_limit do |mash|
    is_a Hashie::Mash

    The mash.limit do
      is_a Fixnum
      ok it >= 1
    end

    The mash.remaining do
      is_a Fixnum
      ok it <= mash.limit
    end
  end

  The client.following_users '_kachick' do |users|
    is_a Array

    The users.sample do
      is_a Hashie::Mash
    end
  end

  The client.following_tags '_kachick' do |tags|
    is_a Array

    The tags.sample do
      is_a Hashie::Mash
    end

    ok tags.any?{|tag|tag.url_name == 'Ruby'}
  end

end

