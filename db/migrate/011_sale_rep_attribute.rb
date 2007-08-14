class SaleRepAttribute < ActiveRecord::Migration
  def self.up
      execute "alter table pos_sales add column rep text"
      execute "update pos_sales set rep = '' where rep is null"
  end

  def self.down
      execute "ALTER TABLE  pos_sales drop column rep"
  end
end
