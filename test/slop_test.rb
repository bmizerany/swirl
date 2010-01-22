require 'contest'
require 'swirl/helpers'

class SlopTest < Test::Unit::TestCase
  include Swirl::Helpers

  test "camalize" do
    assert_equal "foo", Slop.camalize(:foo)
    assert_equal "fooBar", Slop.camalize(:foo_bar)
  end

end
