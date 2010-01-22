module Swirl

  module Model

    module Mappings
      attr_accessor :mappings

      def mappings
        @mappings ||= {}
      end

      def map(key, mapper)
        mappings[key] = mapper
      end
    end

    def mappings
      self.class.mappings
    end

    def self.included(sub)
      sub.extend Model
    end

  end

  class SecurityGroup
    include Model

    attribute "ipPermissions"
  end

end
