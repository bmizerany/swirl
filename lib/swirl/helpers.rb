module Swirl

  module Helpers

    module Expander
      def expand(request)
        root_key = request.keys.first
        request[root_key]
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
