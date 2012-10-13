# coding: utf-8

$VERBOSE = true

require_relative '../lib/qiita'

Qiita.client name: 'Username', password: 'Password' do
  select(queries: ['ruby', 'qiita', 'API']) 
  foreach user_items do |article|
    p "title: #{article.title}"
    p "markdown"
    p article.raw_body
  end
end
