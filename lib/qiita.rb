# qiita - Qiita-API wrapper

# Copyright (c) 2012 Hiroshige Umino
# Copyright (c) 2012 Kenichi Kamiya

# Supporting v1 API
# @see http://qiita.com/docs
module Qiita

  ROOT_URL = 'https://qiita.com/'.freeze

end

require_relative 'qiita/version'
require_relative 'qiita/error'
require_relative 'qiita/client'
