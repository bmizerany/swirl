require 'contest'
require 'swirl/helpers'

class ExpanderTest < Test::Unit::TestCase
  include Swirl::Helpers

  test "pivots on root" do
    response = { "Foo" => { "requestId" => "abc123" } }
    expected = { "requestId" => "abc123" }

    assert_equal expected, Expander.expand(response)
  end

  test "turns item lists into Array" do
    response = { "Foo" => { "groupSet" => { "item" => { "foo" => "bar" } } } }
    expected = { "groupSet" =>  [ { "foo" => "bar" } ] }

    assert_equal expected, Expander.expand(response)
  end

end
