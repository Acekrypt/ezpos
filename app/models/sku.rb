

class Sku < ActiveRecord::Base

    RETURN=Sku.find( DEF::RETURNED_SKU_ID )
    NON_EXISTANT=Sku.find( DEF::NONEXISTANT_SKU_ID )

    composed_of :cost, :class_name => "Money", :mapping => [ %w(cost cents) ]
    composed_of :price, :class_name => "Money", :mapping => [ %w(price cents) ]

    def discontinued?
        deleted_flag == 'Y'
    end

end

