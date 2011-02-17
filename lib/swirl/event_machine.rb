require 'em-http'

module Swirl
  class Base
    def post(body, &blk)
      headers = { "Content-Type" => "application/x-www-form-urlencoded" }

      http = EM::HttpRequest.new(@url.to_s)
      req  = http.post(:head => headers, :body => body)

      req.callback do
        begin
          blk.call(req.response_header.status, req.response)
        rescue => e
          req.fail(e)
        end
      end

      def req.error(&blk)
        errback(&blk)
      end

      req
    end
  end
end
