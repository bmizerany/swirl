require 'contest'
require 'swirl/helpers'

class SlopTest < Test::Unit::TestCase
  include Swirl::Helpers

  test "camalize" do
    assert_equal "foo", Slop.camalize(:foo)
    assert_equal "fooBar", Slop.camalize(:foo_bar)
  end

  test "gets sloppy" do
    slop = Slop.new({"fooBar" => "baz"})
    assert_equal "baz", slop[:foo_bar]
  end

  test "raise InvalidKey if key not found" do
    slop = Slop.new({})
    assert_raises Slop::InvalidKey do
      slop[:not_here]
    end
  end

end
