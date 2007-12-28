
class PosSaleSku < ActiveRecord::Base

    belongs_to :sale, :class_name=>'PosSale', :foreign_key=>:pos_sale_id

    has_many :returns, :class_name=>'PosSaleSkuReturn'


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
        @discount_percent = ( (self.discount / self.undiscounted_price ) * 100 ).round
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
        entry.discount=BigDecimal.zero
        return Array[ entry, ret ]
    end


    def returned?
        ! self.returns.empty?
    end

    def discount_percent=( f )
        @discount_percent=f
        p=self.undiscounted_price
        if @discount_percent > 0
            self.price= p * ( 1-( @discount_percent.to_f/100 ) )
            self.discount=p-self.price
        else
            self.price=p
            self.discount=BigDecimal.zero
        end
        self.tax=self.price * self.tax_rate * self.qty
    end

    def discounted?
        ! self.discount.zero?
    end

    def tax_rate=( rate )
        self.tax=( self.price * rate ) * self.qty
        @rate=rate
    end


    def tax_rate
        return @rate if @rate
        @rate=self.tax/self.price
    end

    def undiscounted_price
        self.price + self.discount
    end

    def undiscounted_price=( new_price )
        self.price=( 1-( @discount_percent.to_f/100 ) ) *  new_price
        self.discount=new_price-self.price
        self.tax = self.price * self.tax_rate * self.qty
    end

    def subtotal
        ( self.price * self.qty ).round(2)
    end

    def undiscounted_subtotal
        ( self.undiscounted_price * self.qty ).round(2)
    end

    def total
        (self.tax+self.subtotal).round(2)
    end

    def total_returned
        (self.price*qty_returned).round(2)
    end

    def total_tax_returned
        return BigDecimal.zero if total_returned.zero?
        total_returned*self.tax_rate
    end
end
