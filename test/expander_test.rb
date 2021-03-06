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
      "group.1" => "foo",
      "group.2" => "bar",
      "group.3" => "baz"
    }

    assert_equal expected, Expander.expand(request)
  end

  test "expands keys with # and Array values to .n. key-values" do
    request = { "foo.#.bar" => ["foo", "bar", "baz"] }

    expected = {
      "foo.1.bar" => "foo",
      "foo.2.bar" => "bar",
      "foo.3.bar" => "baz"
    }

    assert_equal expected, Expander.expand(request)
  end

  test "ignores empty Array values" do
    request = { "group" => [] }
    expected = {}

    assert_equal expected, Expander.expand(request)
  end

  test "converts Key of Range to FromKey ToKey" do
    request = { "Port" => 1..3 }
    expected = { "FromPort" => 1, "ToPort" => 3 }

    assert_equal expected, Expander.expand(request)
  end

end
