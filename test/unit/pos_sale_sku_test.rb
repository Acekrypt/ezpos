require File.dirname(__FILE__) + '/../test_helper'

class PosSaleSkuTest < Test::Unit::TestCase
  fixtures :skus, :customers, :pos_sales, :pos_sale_skus


  def test_from_sku
      s=skus( :non )
      assert_kind_of Sku, s
      pss=PosSaleSku.from_sku( s )
      assert_equal( s.code, pss.code )
  end

  def test_discount
      sku=pos_sale_skus(:b)
      assert_equal( 34.34, sku.price )
      sku.tax_rate=0.0

      sku.qty=1
      assert_equal( 1, sku.qty )

      sku.discount_percent=5
      assert_equal( 32.623, sku.price )
      assert_equal( '$1.72', sku.discount.money )
      assert_equal( 34.34, sku.undiscounted_price )
      assert_equal( 34.34, sku.undiscounted_subtotal )
      assert_equal( 32.623, sku.subtotal )
      assert_equal( 32.623, sku.total )

      sku.discount_percent=10

      assert_equal( BigDecimal.new('30.906') , sku.price )
      assert_equal( 3.434, sku.discount )
      assert_equal( 34.34 , sku.undiscounted_price )
      assert_equal( BigDecimal.new( '34.34' ), sku.undiscounted_subtotal )
      assert_equal( BigDecimal.new( '30.906' ), sku.subtotal )
      assert_equal( BigDecimal.new( '30.906' ), sku.total )

      sku.qty=3
      assert_equal( 3, sku.qty )
      assert_equal( BigDecimal.new( '30.906' ), sku.price )
      assert_equal( BigDecimal.new( '3.434'  ), sku.discount )
      assert_equal( BigDecimal.new( '34.34' ), sku.undiscounted_price )
      assert_equal( BigDecimal.new( '103.02' ), sku.undiscounted_subtotal )
      assert_equal( BigDecimal.new( '92.718' ), sku.subtotal )
      assert_equal( BigDecimal.new( '92.718' ), sku.total )
  end

  def test_tax
      sku=pos_sale_skus(:b)
      assert_equal( 3, sku.qty )
      assert_equal( BigDecimal.new( '34.34' ) , sku.price )
      sku.discount_percent=5.25
      sku.tax_rate=0.0675

      assert_equal( '$32.54', sku.price.money    )
      assert_equal( BigDecimal.new( '32.53715' )  , sku.price )
      assert_equal( BigDecimal.new( '1.80285' )  , sku.discount )
      assert_equal( BigDecimal.new( '97.61145' ) , sku.subtotal )
      assert_equal( '$97.61', sku.subtotal.money )

      assert_equal( BigDecimal.new( '6.588772875' )  , sku.tax )
      assert_equal( '$6.59', sku.tax.money )
      assert_equal( BigDecimal.new( '104.200222875' ), sku.total    )
      assert_equal( '$104.20', sku.total.money )
  end

end

