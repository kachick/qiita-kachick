module Qiita; class Client
  
  module Users

    def user_items(url_name=nil)
      get url_name ? "/users/#{url_name}/items" : '/items'
    end

    def user_stocks(url_name=nil)
      get url_name ? "/users/#{url_name}/stocks" : '/stocks'
    end

    def user(url_name)
      get "/users/#{url_name}"
    end

  end

end; end
