class PosSale < ActiveRecord::Migration

  def self.up
      execute <<-_SQL
      create table pos_sales
      (
       id serial primary key,
       customer_id int not null
         REFERENCES customers(id)
         MATCH FULL
         ON DELETE CASCADE
         ON UPDATE CASCADE,
       occured timestamp not null default now()
       );
      _SQL
      execute "create index pos_sales_index1 on pos_sales( date_trunc('day', occured ) )"
  end

  def self.down
      drop_table :pos_sales
  end


end
