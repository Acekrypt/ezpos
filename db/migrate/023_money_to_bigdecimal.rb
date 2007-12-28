class MoneyToBigdecimal < ActiveRecord::Migration

    def self.chg_type( table, row, type, modifier )
        execute "alter table #{table} add column tmp #{type}"
        execute "update  #{table} set tmp = #{row}#{modifier}"
        execute "alter table #{table} drop column #{row}"
        execute "alter table #{table} rename column tmp to #{row}"
    end

    def self.to_i( table,row )
        chg_type( table.to_s, row.to_s,'int','*100')
    end

    def self.to_m( table,row )
        chg_type( table.to_s, row.to_s,'decimal(15,2)', '::numeric/100' )
    end

    def self.up
        execute 'drop view if exists am_barcoder_items_view'
        to_m :skus, :price
        execute 'create view am_barcoder_items_view as select skus.code AS item_id, skus.descrip AS extended_desc, skus.price from skus'

        to_m :customers, :credit_limit
        to_m :customers, :credit_limit_used
        to_m :pos_daily_receipts, :checks
        to_m :pos_daily_receipts, :cash
        to_m :pos_daily_receipts, :billing
        to_m :pos_daily_receipts, :returns
        to_m :pos_daily_receipts, :credit_cards
        to_m :pos_sale_skus, :price
        to_m :pos_sale_skus, :tax
        to_m :pos_sale_skus, :discount
        to_m :pos_payments,  :amount
        execute 'alter table pos_sale_skus alter column discount set default 0.00'
        execute 'alter table pos_sale_skus alter column price set default 0.00'
        execute 'alter table pos_sale_skus alter column tax set default 0.00'
    end

    def self.down
        to_i :skus, :price
        to_i :customers, :credit_limit
        to_i :customers, :credit_limit_used
        to_i :pos_daily_receipts, :checks
        to_i :pos_daily_receipts, :cash
        to_i :pos_daily_receipts, :billing
        to_i :pos_daily_receipts, :returns
        to_i :pos_daily_receipts, :credit_cards
        to_i :pos_sale_skus, :price
        to_i :pos_sale_skus, :tax
        to_i :pos_sale_skus, :discount
        to_i :pos_payments,  :amount
    end
end
