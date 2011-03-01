module Swirl

  module Helpers

    module Compactor

      def compact(response)
        root_key = response.keys.first
        base = response[root_key]
        compact!(base)
      end
      module_function :compact

      def compact!(data)
        data.inject({}) do |com, (key, value)|
          if value.is_a?(Hash)
            converted = if value.has_key?("item") || value.has_key?("member")
              items = value["item"] || value ["member"]
              items ||= []
              items = items.is_a?(Array) ? items : [items]
              items.map {|item| compact!(item) }
            else
              []
            end
            com[key] = converted
          elsif key == "xmlns"
            next(com)
          else
            com[key] = value
          end
          com
        end
      end
      module_function :compact!

    end

    module Expander
      def expand(request)
        request.inject({}) do |exp, (key, value)|
          next(exp) if !key.is_a?(String)

          case value
          when Array
            key = "#{key}.#" if key !~ /#/
            value.each_with_index do |val, n|
              # We must use n+1 because some api's do not allow a 0 index
              exp[key.gsub("#", (n+1).to_s)] = val
            end
          when Range
            exp["From#{key}"] = value.min
            exp["To#{key}"] = value.max
          else
            exp[key] = value
          end
          exp
        end
      end
      module_function :expand
    end

    module Slop
      class InvalidKey < StandardError ; end

      def self.new(response)
        sloppy = Hash.new do |hash, key|
          camalized = Slop.camalize(key)
          raise InvalidKey, key if !response.has_key?(camalized)
          response[camalized]
        end
      end

      def self.camalize(stringish)
        head, tail = stringish.to_s.split("_")
        rest = Array(tail).map! {|part| part.capitalize }
        [head, *rest].join
      end

      def slopify(response)
        Slop.new(response)
      end
    end

  end

end
