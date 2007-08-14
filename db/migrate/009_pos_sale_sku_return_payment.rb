class PosSaleSkuReturnPayment < ActiveRecord::Migration
  def self.up
      execute 'alter table pos_sale_sku_returns add column pos_payment_type_id int'
      execute "update pos_sale_sku_returns set pos_payment_type_id=(select id from pos_payment_types where name='Cash')"
      execute 'alter table pos_sale_sku_returns alter column pos_payment_type_id set not null'
      execute 'alter table pos_sale_sku_returns add constraint pos_sale_sku_returns_pos_payment_types_id_fkey foreign key (pos_payment_type_id) references pos_payment_types(id) match full'
  end

  def self.down
      execute 'alter table pos_sale_sku_returns drop column pos_payment_type_id'
  end
end
