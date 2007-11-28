require File.dirname(__FILE__) + '/../test_helper'

class PosSaleTest < Test::Unit::TestCase
  fixtures :customers, :pos_sales, :pos_sale_skus, :pos_payments


  def test_between
      sales=PosSale.find_on_date( Date.new( 2005, 03, 01 ) )
      assert_equal( 1, sales.size )

      sales=PosSale.find_between_dates( Date.new( 2005, 03, 01 ),Date.new( 2005, 05, 01 ) )
      assert_equal( 3, sales.size )
  end

  def test_customer
      sale=pos_sales( :sale )
      assert( sale.customer )
  end

  def test_skus
      assert_equal( pos_sales( :sale).skus.size, 3 )
  end

  def test_total
      sale=pos_sales( :sale )
      assert_equal( sale.tax+sale.subtotal, sale.total )
      assert_equal( BigDecimal.new('160.68'), sale.total )
  end

  def test_subtotal
      assert_equal( 154.04, pos_sales( :sale).subtotal )
  end

  def test_tax
      assert_equal(6.64, pos_sales( :sale).tax )
  end

  def test_change
      assert_equal( BigDecimal.new('8.32'), pos_sales( :sale).change_given )
  end

end
