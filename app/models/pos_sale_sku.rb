
class PosSaleSku < ActiveRecord::Base

    belongs_to :sale, :class_name=>'PosSale'

    has_many :returns, :class_name=>'PosSaleSkuReturn'

    composed_of :price, :class_name=>'Money', :mapping => [ %w(price cents) ]
    composed_of :tax, :class_name=>'Money', :mapping => [ %w(tax cents) ]
    composed_of :discount, :class_name=>'Money', :mapping => [ %w(discount cents) ]

    def PosSaleSku.from_sku( sku )
        pps=PosSaleSku.new
        pps.code = sku.code
        pps.descrip = sku.descrip
        pps.price = sku.price
        pps.qty = 1
        pps.uom = sku.uom
        pps
    end

    def discount_percent
        return @discount_percent if @discount_percent
        return 0 if self.discount.zero? || self.undiscounted_price.zero?
        @discount_percent=((self.discount.cents.to_f/self.undiscounted_price.cents.to_f)*100).round
        return @discount_percent
    end

    def qty_returned
        num=0
        self.returns.each{ | ret | num+=ret.qty }
        num
    end

    def qty_unreturned
        self.qty-self.qty_returned
    end

    def return( payment_type, q,reason )
        raise ArgumentError.new( "Return Qty must be less than #{qty_unreturned}" ) if q > qty_unreturned
        ret=PosSaleSkuReturn.new(  :pos_payment_type=>payment_type, :qty=>q, :sku=>self, :reason=>reason, :occured=>Time.now )
        ret.save
        entry=PosSaleSku.from_sku( Sku::RETURN )
        entry.qty=q
        entry.tax=self.tax*-1
        entry.descrip=self.code + '-' + self.descrip
        entry.price=self.price*-1
        entry.discount=Money::ZERO
        return Array[ entry, ret ]
    end


    def returned?
        ! self.returns.empty?
    end

    def discount_percent=( f )
        @discount_percent=f
        p=self.undiscounted_price
        if @discount_percent > 0
            self.price=Money.new( p * ( 1-( @discount_percent.to_f/100 ) ) )
            self.discount=p-self.price
        else
            self.price=p
            self.discount=Money::ZERO
        end
        self.tax=Money.new( self.price * self.tax_rate ) * self.qty
    end

    def discounted?
        ! self.discount.zero?
    end

    def tax_rate=( rate )
        self.tax=Money.new( self.price * rate ) * self.qty
        @rate=rate
    end


    def tax_rate
        return @rate if @rate
        @rate=self.tax.cents.to_f/self.price.cents.to_f
    end

    def undiscounted_price
        self.price + self.discount
    end

    def undiscounted_price=( new_price )
        self.price=Money.new( new_price * ( 1-( @discount_percent.to_f/100 ) ) )
        self.discount=new_price-self.price
        self.tax=Money.new( self.price * self.tax_rate ) * self.qty
    end

    def subtotal
        ( self.price * self.qty )
    end

    def undiscounted_subtotal
        ( self.undiscounted_price * self.qty )
    end

    def total
        self.tax+self.subtotal
    end

    def total_returned
        self.price*qty_returned
    end

    def total_tax_returned
        return Money::ZERO if total_returned.zero?
        Money.new( total_returned.cents*self.tax_rate )
    end
end
