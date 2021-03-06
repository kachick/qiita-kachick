# coding: utf-8

$VERBOSE = true

require_relative '../lib/qiita'

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
  