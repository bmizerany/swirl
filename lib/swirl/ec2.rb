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
    include Helpers::Slop

    def self.credentials(name=:default, file="~/.swirl")
      YAML.load_file(File.expand_path(file))[name]
    end

    def initialize(options=self.class.credentials)
      @aws_access_key_id      = options[:aws_access_key_id]
      @aws_secret_access_key  = options[:aws_secret_access_key]
      @hmac       = HMAC::SHA256.new(@aws_secret_access_key)
      @host       = options[:host]      || 'ec2.amazonaws.com'
      @port       = options[:port]      || 443
      @scheme     = options[:scheme]    || 'https'
      @url        = "#{@scheme}://#{@host}:#{@port}"
    end

    def escape(value)
      CGI.escape(value).gsub(/\+/, "%20")
    end

    def compile_sorted_form_data(query)
      valid = query.reject {|_, v| v.nil? }
      valid.sort.map {|k,v| [k, escape(v)] * "=" } * "&"
    end

    def compile_signature(method, body)
      string_to_sign = [method, @host, "/", body] * "\n"
      hmac = @hmac.update(string_to_sign)
      encoded_sig = Base64.encode64(hmac.digest).chomp
      escape(encoded_sig)
    end

    def call(action, query={})
      response = call!(action, expand(query))
      slopify(compact(response))
    end

    def call!(action, query={})
      # Hard coding this here until otherwise needed
      method = "POST"

      query["Action"] = action
      query["AWSAccessKeyId"] = @aws_access_key_id
      query["SignatureMethod"] = "HmacSHA256"
      query["SignatureVersion"] = "2"
      query["Timestamp"] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      query["Version"] = "2009-11-30"

      body = compile_sorted_form_data(query)
      body += "&" + ["Signature", compile_signature(method, body)].join("=")

      response = post(body)
      Crack::XML.parse(response.body)
    end

    def post(body)
      url = URI(@url)

      headers = { "Content-Type" => "application/x-www-form-urlencoded" }

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url.request_uri, headers)
      request.body = body

      http.request(request)
    end

  end

end
