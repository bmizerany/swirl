require 'contest'
require 'swirl/aws'

class AwsTest < Test::Unit::TestCase

  test "raises InvalidRequest on ErrorResponse" do
    e = Swirl::AWS.new(:ec2, :aws_access_key_id => 'AKIA', :aws_secret_access_key => 'secret')
    def e.call!(*args, &blk)
      doc = {"ErrorResponse"=>{"Error"=>{"Code"=>"CertificateNotFound", "Type"=>"Sender"}}}
      blk.call [400, doc]
    end
    assert_raise(Swirl::InvalidRequest) { e.call "CreateLoadBalancer", {} }
  end

end
