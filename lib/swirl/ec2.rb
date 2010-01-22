require 'yaml'
require 'cgi'
require 'base64'

require 'restclient'
require 'crack/xml'
require 'hmac-sha2'

module Swirl

  class EC2

    module ResponseNormalizer

      def self.call(response)
        root = response.keys.first
        call!(response[root])
      end

      def self.call!(response)
        response.inject({}) do |norm, (key, value)|
          case key
          when /Set$/
            if value.nil?
              norm[key] = []
            else
              item  = value["item"]

              ## Note
              # We can't use Array() here because the
              # value of 'item' can be a Hash which
              # returns a zipped Array on #to_a
              items = item.is_a?(Array) ? item : [item]

              norm[key] = items.map {|v| call!(v) }
            end
          when "xmlns"
            # noop
          else
            next norm if value.nil?
            norm[key] = value
          end
          norm
        end
      end

    end

    module RequestNormalizer

      def self.call(request)
        request.inject({}) do |norm, (key, value)|

          next(norm) if key.is_a?(Symbol)

          case value
          when Array
            value.each_with_index do |val, n|
              norm["#{key}.#{n}"] = val
            end
          when Range
            norm["From#{key}"] = value.min.to_s
            norm["To#{key}"] = value.max.to_s
          else
            norm[key] = value.to_s
          end
          norm
        end
      end

    end

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
      normalized_query = RequestNormalizer.call(query)
      response = call!(action, normalized_query)
      ResponseNormalizer.call(response)
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

      response = RestClient.post(
        @url,
        body,
        "Content-Type" => "application/x-www-form-urlencoded"
      )

      Crack::XML.parse(response)
    end

  end

end
