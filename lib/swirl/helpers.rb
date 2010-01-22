module Swirl

  module Helpers

    module Expander

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

      def expand(request)
        root_key = request.keys.first
        base = request[root_key]
        base.inject({}) do |exp, (key, value)|
          if Lists.include?(key)
            items = value["item"]
            items ||= []
            items = items.is_a?(Array) ? items : [items]
            exp[key] = items
          else
            exp[key] = value
          end
          exp
        end
      end
      module_function :expand

    end

    module Compactor
      def compact(response)
      end
      module_function :compact
    end

  end

end
