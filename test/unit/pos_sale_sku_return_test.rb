require File.dirname(__FILE__) + '/../test_helper'

class PosSaleSkuReturnTest < Test::Unit::TestCase
  fixtures :pos_sales, :pos_sale_skus, :pos_sale_sku_returns

  # Replace this with your real tests.
  def test_truth
    assert_kind_of PosSaleSkuReturn, pos_sale_sku_returns(:pos_sale_sku_return_1)
  end


end
