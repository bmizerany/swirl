module Swirl

  module Expander
    def expand(request)
    end
    module_function :expand
  end

  module Compactor
    def compact(response)
    end
    module_function :compact
  end


  class Request
    def initialize(command, credentials)
      @command = command
    end

    def call(params)
    end

    def compact(params)
    end

    def expand(response)
    end
  end

end
