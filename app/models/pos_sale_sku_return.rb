class PosSaleSkuReturn < ActiveRecord::Base

    belongs_to :sku, :class_name=>'PosSaleSku', :foreign_key=>'pos_sale_sku_id'


    def self.find_on_date( date )
        self.find( :all, :conditions => [ "date_trunc( 'day',pos_sale_sku_returns.occured) = ?", date.strftime('%Y-%m-%d') ],  :include=>[:sku], :order => "pos_sale_sku_returns.occured desc" )
    end

    def self.find_between_dates( begining, ending )
        self.find( :all, :conditions => [ "date_trunc( 'day',pos_sale_sku_returns.occured) >= ? and date_trunc('day',pos_sale_sku_returns.occured) <= ?", begining.strftime('%Y-%m-%d'),ending.strftime('%Y-%m-%d') ],  :include=>[:sku ], :order => "pos_sale_sku_returns.occured desc" )
    end
end
