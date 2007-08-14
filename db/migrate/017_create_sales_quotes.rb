class CreateSalesQuotes < ActiveRecord::Migration
  def self.up
      execute 'CREATE  INDEX "skus_index3" ON skus ( upper(code) )'

      execute "alter table skus add column tmp bigint"
      execute "update skus set tmp = cost*100"
      execute "alter table skus drop column cost"
      execute "alter table skus rename column tmp to cost"

      create_table :sales_quotes do |t|
          t.column :recipient_name, :string, :default=>'Unknown'
          t.column :created_on, :datetime, :default=>'now()'
          t.column :last_printed_on, :datetime, :default=>'now()'
          t.column :employee_id, :int, :null=>false
          # t.column :name, :string
      end

      create_table( 'sales_quote_skus' ) do |t|
          t.column :sales_quote_id, :int
          t.column :code, :string
          t.column :qty, :int, :default=>1
          t.column :descrip, :string
          t.column :um, :string
          t.column :price, :int
          t.column :sku_id, :int, :null=>false
          t.column :present_order, :int
      end

      execute "alter table sales_quote_skus add constraint sales_quotes_skus_fkey1 foreign key ( sku_id ) references skus(id) on delete cascade"


  end

  def self.down
      drop_table :sales_quote_skus
      drop_table :sales_quotes
      remove_index :skus, :name=>:skus_index2

      execute "alter table skus add column tmp float"
      execute "update skus set tmp = cost/100"
      execute "alter table skus drop column cost"
      execute "alter table skus rename column tmp to cost"
  end
end
