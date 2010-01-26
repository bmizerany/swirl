require 'yaml'
require 'cgi'
require 'base64'
require 'net/https'

require 'crack/xml'
require 'hmac-sha2'

require 'swirl/helpers'

module Swirl

  class EC2
    include Helpers::Compactor
    include Helpers::Expander

    def self.options(name=:default, file="~/.swirl")
      YAML.load_file(File.expand_path(file))[name]
    end

    def initialize(options=self.class.options)
      @aws_access_key_id = options[:aws_access_key_id]
      @aws_secret_access_key = options[:aws_secret_access_key]
      @hmac = HMAC::SHA256.new(@aws_secret_access_key)
      @version = options[:version] || "2009-11-30"
      @url = URI(options[:url] || "https://ec2.amazonaws.com")
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
    def call(action, query={})
      compact(call!(action, expand(query)))
    end

    def call!(action, query={})
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

      response = post(body)
      Crack::XML.parse(response.body)
    end

    def post(body)
      headers = { "Content-Type" => "application/x-www-form-urlencoded" }

      http = Net::HTTP.new(@url.host, @url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(@url.request_uri, headers)
      request.body = body

      http.request(request)
    end

  end

end
