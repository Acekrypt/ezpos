require File.dirname(__FILE__) + '/../test_helper'

class PosDailyReceiptTest < Test::Unit::TestCase
  fixtures :pos_daily_receipts

  # Replace this with your real tests.
  def test_truth
    assert_kind_of PosDailyReceipt, pos_daily_receipts(:first)
  end
end
