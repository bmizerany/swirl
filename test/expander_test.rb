require 'contest'
require 'swirl/helpers'

class ExpanderTest < Test::Unit::TestCase
  include Swirl::Helpers

  test "leaves params as is by default" do
    request = { "foo" => "bar" }

    assert_equal request, Expander.expand(request)
  end

  test "ignores non-String keys" do
    request = { "foo" => "bar", :ignore => "test" }
    expected = { "foo" => "bar" }

    assert_equal expected, Expander.expand(request)
  end

end
