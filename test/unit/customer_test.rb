require File.dirname(__FILE__) + '/../test_helper'



class CustomerTest < Test::Unit::TestCase
    fixtures :customers

    def setup
        @special=customers(:special)
        @normal=customers(:normal)
    end

    def test_types
        assert_kind_of Customer, @special
        assert_kind_of Customer, @normal
    end
    
    def test_address
        assert_match( /Euclid\nApt/,@special.address )
    end

    def test_reseller
        assert( @special.reseller? )
        assert( ! @normal.reseller? )
    end

    def test_tax_exempt
        assert( @special.tax_exempt? )
        assert( ! @normal.tax_exempt? )
    end


end
