require 'contest'
require 'swirl/helpers'

class ExpanderTest < Test::Unit::TestCase
  include Swirl::Helpers

  test "pivots on root" do
    response = { "DesribeInstancesResponse" => { "requestId" => "abc123" } }
    expected = { "requestId" => "abc123" }

    assert_equal expected, Expander.expand(response)
  end

end
