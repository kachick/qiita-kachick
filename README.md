qiita
========

* ***This repository is archived***
* ***No longer maintained***
* ***All versions have been yanked from https://rubygems.org for releasing valuable namespace for others***

Description
-----------

Ruby wrapper for Qiita API

Features
--------

See [API-v1 doc](http://qiita.com/docs)

Usage
-----

### Classic

Try this

```ruby
# coding: utf-8
require 'qiita'

client = Qiita::Client.new
p client.following_users 'AnyUser'
p client.following_tags 'AnyUser'
p client.select(queries: ['ruby', 'qiita', 'API'])

client.auth name: 'Username', password: 'Password'
p client.token
p client.rate_limit
p items = client.user_items

client.foreach items do |article|
  p "title: #{article.title}"
  p "markdown"
  p article.raw_body
end
```

### DSL Like

```ruby
# coding: utf-8
require 'qiita'

Qiita.client name: 'Username', password: 'Password' do
  p select(queries: ['ruby', 'qiita', 'API']) 
  foreach user_items do |article|
    p "title: #{article.title}"
    p "markdown"
    p article.raw_body
  end
end
```

### More API

See code :)

Requirements
-------------

* Ruby - [1.9.2 or later](http://travis-ci.org/#!/kachick/qiita-kachick)
* json
* faraday
* faraday_middleware
* [optionalargument](https://github.com/kachick/optionalargument)

License
--------

The MIT X11 License  
See MIT-LICENSE for further details.

This repository is forked from [qiita](https://github.com/yaotti/qiita-rb)
Thanks!
