class CreditHold < ActiveRecord::Migration

    def self.chg_type( row, type, modifier )
        execute "alter table customers add column tmp #{type}"
        execute "update customers set tmp = #{row}#{modifier}100"
        execute "alter table customers drop column #{row}"
        execute "alter table customers rename column tmp to #{row}"
    end

    def self.up
        chg_type( 'credit_limit','int', '*' )
        chg_type( 'acct_balance','int', '*' )
    end

    def self.down
        chg_type( 'credit_limit','numeric(10,2)','/' )
        chg_type( 'acct_balance','numeric(10,2)','/' )
    end
end
