require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :customers

  # Replace this with your real tests.
  def test_truth
    assert_kind_of User, customers(:special)
  end
end
