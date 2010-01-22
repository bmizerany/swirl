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

  test "expands Array values to .n key-values" do
    request = { "group" => ["foo", "bar", "baz"] }

    expected = {
      "group.0" => "foo",
      "group.1" => "bar",
      "group.2" => "baz"
    }

    assert_equal expected, Expander.expand(request)
  end

end
