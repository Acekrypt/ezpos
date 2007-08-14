class SalesQuoteSku < ActiveRecord::Base

    belongs_to :sales_quote
    composed_of :price, :class_name => "Money", :mapping => [ %w(price cents) ]
    belongs_to :sku

    def total
        self.price * self.qty
    end

    def self.from_sku( sku )
        s=SalesQuoteSku.new
        s.code = sku.code
        s.sku=sku
        s.uom = sku.uom
        s.descrip = ( (sku.descrip=~/\w/) ? sku.descrip : 'Blank' )
        s.price = sku.price1
        s
    end
end
