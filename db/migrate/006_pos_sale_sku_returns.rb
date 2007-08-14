class PosSaleSkuReturns < ActiveRecord::Migration
  def self.up
      execute <<-_SQL
      create table pos_sale_sku_returns
      (
       id serial primary key,
       qty int not null,
       pos_sale_sku_id int not null
          REFERENCES pos_sale_skus(id)
	  MATCH FULL
	  ON DELETE CASCADE
	  ON UPDATE CASCADE,
       reason text not null,
       occured timestamp not null default now()
       );
      _SQL

      execute "create index pos_sale_sku_returns_indx1 on pos_sale_sku_returns( pos_sale_sku_id )"
  end

  def self.down
      drop_table :pos_sale_sku_returns
  end
end
