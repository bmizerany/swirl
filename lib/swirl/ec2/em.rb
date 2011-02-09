require 'swirl/ec2'
require 'em-http'

module Swirl
  class EC2
    def post(body, &blk)
      headers = { "Content-Type" => "application/x-www-form-urlencoded" }

      http = EM::HttpRequest.new(@url.to_s)
      req  = http.post(:head => headers, :body => body)

      req.callback do
        blk.call(req.response_header.status, req.response)
      end

      req.errback do
        raise "Invalid HTTP Request: #{@url}\n"+req.response
      end
    end
  end
end
