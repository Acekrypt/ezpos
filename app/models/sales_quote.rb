class SalesQuote < ActiveRecord::Base

    has_many :skus, :class_name=>'SalesQuoteSku', :order=>'present_order', :dependent=>:destroy, :include=>'sku'
    belongs_to :employee

end
