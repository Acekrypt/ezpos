require File.dirname(__FILE__) + '/../test_helper'

class PosPaymentTest < Test::Unit::TestCase
  fixtures :pos_sales, :pos_payments

  # Replace this with your real tests.
  def test_truth
    assert_kind_of PosPayment, pos_payments(:pos_payment_7)
  end
end
