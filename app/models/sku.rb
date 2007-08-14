

class Sku < ActiveRecord::Base

    composed_of :cost, :class_name => "Money", :mapping => [ %w(cost cents) ]
    composed_of :price, :class_name => "Money", :mapping => [ %w(price cents) ]

    def discontinued?
        deleted_flag == 'Y'
    end

end

