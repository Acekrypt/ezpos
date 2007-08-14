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
      assert_equal( Money.new( 3434 ) , sku.price )
      sku.tax_rate=0.0

      sku.qty=1
      assert_equal( 1, sku.qty )

      sku.discount_percent=5
      assert_equal( Money.new( 3262 ) , sku.price )
      assert_equal( Money.new( 172 ), sku.discount )
      assert_equal( Money.new( 3434 ), sku.undiscounted_price )
      assert_equal( Money.new( 3434 ), sku.undiscounted_subtotal )
      assert_equal( Money.new( 3262 ), sku.subtotal )
      assert_equal( Money.new( 3262 ), sku.total )


      sku.discount_percent=10
      assert_equal( Money.new( 2936 ) , sku.price )
      assert_equal( Money.new( 326 ), sku.discount )
      assert_equal( Money.new( 3262 ) , sku.undiscounted_price )
      assert_equal( Money.new( 3262 ), sku.undiscounted_subtotal )
      assert_equal( Money.new( 2936 ), sku.subtotal )
      assert_equal( Money.new( 2936 ), sku.total )

      sku.qty=3
      assert_equal( 3, sku.qty )
      assert_equal( Money.new( 2936 ), sku.price )
      assert_equal( Money.new( 326  ), sku.discount )
      assert_equal( Money.new( 3262 ), sku.undiscounted_price )
      assert_equal( Money.new( 9786 ), sku.undiscounted_subtotal )
      assert_equal( Money.new( 8808 ), sku.subtotal )
      assert_equal( Money.new( 8808 ), sku.total )


  end

  def test_tax
      sku=pos_sale_skus(:b)
      assert_equal( 3, sku.qty )
      assert_equal( Money.new( 3434 ) , sku.price )
      sku.discount_percent=5.25
      sku.tax_rate=0.0675

      assert_equal( Money.new( 3254 ) , sku.price    )
      assert_equal( Money.new( 180 )  , sku.discount )
      assert_equal( Money.new( 9762 ) , sku.subtotal )
      assert_equal( Money.new( 659 )  , sku.tax      )
      assert_equal( Money.new( 10421 ), sku.total    )

  end

end

