module Swirl

  module Helpers

    module Compactor

      Lists = [
        "keySet",
        "groupSet",
        "blockDeviceMapping",
        "instancesSet",
        "reservationSet",
        "imagesSet",
        "ownersSet",
        "executableBySet",
        "securityGroupSet",
        "ipPermissions",
        "ipRanges",
        "groups",
        "securityGroupInfo",
        "add",
        "remove",
        "launchPermission",
        "productCodes",
        "availabilityZoneSet",
        "availabilityZoneInfo",
        "publicIpsSet",
        "addressesSet"
      ]

      def compact(response)
        root_key = response.keys.first
        base = response[root_key]
        compact!(base)
      end
      module_function :compact

      def compact!(data)
        data.inject({}) do |com, (key, value)|
          if Lists.include?(key)
            converted = if value && value.has_key?("item")
              items = value["item"]
              items ||= []
              items = items.is_a?(Array) ? items : [items]
              items.map {|item| compact!(item) }
            else
              []
            end
            com[key] = converted
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
            value.each_with_index do |val, n|
              exp["#{key}.#{n}"] = val
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

  end

end
