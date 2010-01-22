require 'contest'
require 'swirl/helpers'

class ExpanderTest < Test::Unit::TestCase
  include Swirl::Helpers

  test "leaves params as is by default" do
    request = { "foo" => "bar" }

    assert_equal request, Expander.expand(request)
  end

end
