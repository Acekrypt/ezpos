

class Sku < ActiveRecord::Base

    RETURN=Sku.find(:first,:conditions=>['id=?',DEF::RETURNED_SKU_ID] )
    NON_EXISTANT=Sku.find( :first, :conditions=>['id=?',DEF::NONEXISTANT_SKU_ID ] )

    def discontinued?
        deleted_flag == 'Y'
    end

end

