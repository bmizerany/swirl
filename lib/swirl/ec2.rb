require 'swirl/aws'

$stderr.puts "WARNING: Requiring 'swirl' or 'swirl/ec2' will be deprecated.  Require 'swirl/aws' instead."

module Swirl

  # Compat
  class EC2
    def self.new(options)
      $stderr.puts "WARNING: Swirl::EC2 will be deprecated.  Use Swirl::AWS.new(:ec2) instead"
      return AWS.new(:ec2, options)
    end
  end

end
