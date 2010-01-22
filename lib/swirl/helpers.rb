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
        base.inject({}) do |exp, (key, value)|
          if Lists.include?(key)
            converted = if value && value.has_key?("item")
              items = value["item"]
              items ||= []
              items = items.is_a?(Array) ? items : [items]
            else
              []
            end
            exp[key] = converted
          else
            exp[key] = value
          end
          exp
        end
      end
      module_function :compact

    end

    module Expander
      def expand(request)
      end
      module_function :expand
    end

  end

end
