require 'cgi'
require 'base64'
require 'net/https'

require 'crack/xml'
require 'hmac-sha2'

require 'swirl/helpers'


module Swirl

  ## Errors
  class InvalidRequest < StandardError ; end


  # Compat
  class EC2
    def self.new(options)
      $stderr.puts "WARNING: Swirl::EC2 will be deprecated.  Use Swirl::AWS.new(:ec2) instead"
      return AWS.new(:ec2, options)
    end
  end


  class AWS
    include Helpers::Compactor
    include Helpers::Expander

    @services = {}

    def self.services
      # This must be modified using `service`
      @services.dup
    end

    def self.service(name, url, version)
      @services[name] = { :url => url, :version => version }
    end

    # Default Services
    service :ec2, "https://ec2.amazonaws.com", "2010-11-15"


    def initialize(*args)
      opts = args.last.is_a?(Hash) ? args.pop : Hash.new
      name = args.shift

      service = self.class.services[name] || {}
      opts    = service.merge(opts)

      @url = opts[:url] ||
        raise(ArgumentError, "No url given")

      # Convert this here for future reference
      @url = URI(@url)

      @version = opts[:version] ||
        raise(ArgumentError, "No version given")

      @aws_access_key_id  = \
        ENV["AWS_ACCESS_KEY_ID"] ||
        opts[:aws_access_key_id] ||
        raise(ArgumentError, "No aws_access_key_id given")

      @aws_secret_access_key = \
        ENV["AWS_SECRET_ACCESS_KEY"] ||
        opts[:aws_secret_access_key] ||
        raise(ArgumentError, "No aws_secret_access_key given")

      @hmac = HMAC::SHA256.new(@aws_secret_access_key)
    end

    def escape(value)
      CGI.escape(value).gsub(/\+/, "%20")
    end

    def compile_sorted_form_data(query)
      valid = query.reject {|_, v| v.nil? }
      valid.sort.map {|k,v| [k, escape(v)] * "=" } * "&"
    end

    def compile_signature(method, body)
      string_to_sign = [method, @url.host, "/", body] * "\n"
      hmac = @hmac.update(string_to_sign)
      encoded_sig = Base64.encode64(hmac.digest).chomp
      escape(encoded_sig)
    end

    ##
    # Execute an EC2 command, expand the input,
    # and compact the output
    #
    # Examples:
    #   ec2.call("DescribeInstances")
    #   ec2.call("TerminateInstances", "InstanceId" => ["i-1234", "i-993j"]
    #
    def call(action, query={}, &blk)
      call!(action, expand(query)) do |code, data|
        case code
        when 200
          response = compact(data)
        when 400...500
          messages = Array(data["Response"]["Errors"]).map {|_, e| e["Message"] }
          raise InvalidRequest, messages.join(",")
        else
          msg = "unexpected response #{code} -> #{data.inspect}"
          raise InvalidRequest, msg
        end

        if blk
          blk.call(response)
        else
          response
        end
      end
    end

    def call!(action, query={}, &blk)
      # Hard coding this here until otherwise needed
      method = "POST"

      query["Action"] = action
      query["AWSAccessKeyId"] = @aws_access_key_id
      query["SignatureMethod"] = "HmacSHA256"
      query["SignatureVersion"] = "2"
      query["Timestamp"] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      query["Version"] = @version

      body = compile_sorted_form_data(query)
      body += "&" + ["Signature", compile_signature(method, body)].join("=")

      post(body) do |code, xml|
        if ENV["SWIRL_LOG"]
          puts response.body
        end

        data = Crack::XML.parse(xml)
        blk.call(code, data)
      end
    end

    def post(body, &blk)
      headers = { "Content-Type" => "application/x-www-form-urlencoded" }

      http = Net::HTTP.new(@url.host, @url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(@url.request_uri, headers)
      request.body = body

      response = http.request(request)
      blk.call(response.code.to_i, response.body)
    end

    def inspect
      "<#{self.class.name} version: #{@version} url: #{@url} aws_access_key_id: #{@aws_access_key_id}>"
    end

  end

end
