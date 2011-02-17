module Swirl
  Services = {
   "EC2" => {"url" => "https://ec2.amazonaws.com",
             "version" => "2010-11-15"},
   "IAM" => {"url" => "https://iam.amazonaws.com",
             "version" => "2010-05-08"}
  }

  class EC2 < Service
    def initialize(options)
      @url = URI(Services["EC2"]["url"])
      @version ||= options[:version] || Services["EC2"]["version"]
      super
    end
  end

  class IAM < Service
    def initialize(options)
      @url = URI(Services["IAM"]["url"])
      @version ||= options[:version] || Services["IAM"]["version"]
      super
    end
  end
end
