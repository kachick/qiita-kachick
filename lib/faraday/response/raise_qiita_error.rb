module Faraday

  class Response::RaiseQiitaError < Response::Middleware

    def on_complete(response)
      if error = Qiita::ERRORS[response[:status]]
        raise error, error_message(response)
      end
    end

    def error_message(response)
      body = response[:body]
      return unless body
      message = body['error']
      return unless message.empty?
      
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{response[:status]}"
    end

  end

end
