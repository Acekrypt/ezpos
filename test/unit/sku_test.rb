require File.dirname(__FILE__) + '/../test_helper'

class SkuTest < Test::Unit::TestCase
  fixtures :skus, :customers

    def setup
        @ret=skus(:return)
        @non=skus(:non)
    end

    def test_truth
        assert_kind_of Sku, @ret
    end

    def test_discounted
        assert( ! @ret.discontinued? )
    end

    def test_discounted_w_stock
        assert( ! @ret.discontinued_with_stock? )
    end

    def test_webonly
        assert( @ret.webonly? )
    end

    def test_price
        assert_kind_of( BigDecimal, @ret.price1 )
        assert_equal( "$0.00", @ret.price1.money )
        assert_equal( BigDecimal.new('0'), @ret.price )

        customer=customers( :special )
        assert_kind_of Customer, customer

        assert_equal( BigDecimal.new( '555' ), @ret.price( customer ) )
    end


end
