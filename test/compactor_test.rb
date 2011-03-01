require 'contest'
require 'swirl/helpers'

class CompactorTest < Test::Unit::TestCase
  include Swirl::Helpers

  test "pivots on root" do
    response = { "Foo" => { "requestId" => "abc123" } }
    expected = { "requestId" => "abc123" }

    assert_equal expected, Compactor.compact(response)
  end

  test "ignores xmlns" do
    response = { "Foo" => { "requestId" => "abc123", "xmlns" => "suckit" } }
    expected = { "requestId" => "abc123" }

    assert_equal expected, Compactor.compact(response)
  end

  test "pivots list keys on item" do
    response = { "Foo" => { "groupSet" => { "item" => [{ "foo" => "bar" }] } } }
    expected = { "groupSet" =>  [ { "foo" => "bar" } ] }

    assert_equal expected, Compactor.compact(response)
  end

  test "pivots list keys item and converts to Array not already an Array" do
    response = { "Foo" => { "groupSet" => { "item" => { "foo" => "bar" } } } }
    expected = { "groupSet" =>  [ { "foo" => "bar" } ] }

    assert_equal expected, Compactor.compact(response)
  end

  test "pivots list keys item and makes empty Array if nil" do
    response = { "Foo" => { "groupSet" => { "item" => nil } } }
    expected = { "groupSet" =>  [] }

    assert_equal expected, Compactor.compact(response)
  end

  test "traverses list values and compacts" do
    response = {
      "Foo" => {
        "groupSet" => {
          "item" => {
            "ipPermissions" => {
              "item" => {
                "proto" => "tcp"
              }
            }
          }
        }
      }
    }

    expected = {
      "groupSet" => [
        { "ipPermissions" => [ { "proto" => "tcp" } ] }
      ]
    }

    assert_equal expected, Compactor.compact(response)
  end

end
