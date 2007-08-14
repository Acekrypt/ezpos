class PosSaleSku < ActiveRecord::Migration
  def self.up
      execute <<-_SQL
      create table pos_sale_skus
      (
       id serial primary key,
       pos_sale_id int not null
         REFERENCES pos_sales(id)
         MATCH FULL
         ON DELETE CASCADE
         ON UPDATE CASCADE,
       code text NOT NULL,
       descrip text NOT NULL,
       um text NOT NULL,
       price int NOT NULL,
       qty int NOT NULL default 1,
       tax int not null,
       discount int NOT NULL default 0
       );
      _SQL
  end

  def self.down
      drop_table :pos_sale_skus
  end
end
