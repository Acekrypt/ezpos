class ReturnsTypeUpdate < ActiveRecord::Migration
  def self.up
      execute <<EOS;
update pos_sale_sku_returns set payment_type = case pos_payment_type_id
when 1 then 'CreditCardTerminal'
when 2 then 'Cash'
when 3 then 'Check'
when 4 then 'Billing'
when 5 then 'GiftCard'
when 6 then 'CreditCard'
else 'UNK'
end
EOS
      execute 'alter table pos_sale_sku_returns alter column payment_type set not null'
      remove_column  'pos_sale_sku_returns', 'pos_payment_type_id'

  end


  def self.down
      add_column  'pos_sale_sku_returns', 'pos_payment_type_id', :int
      execute <<EOS;
update pos_sale_sku_returns set pos_payment_type_id = case payment_type
when 'CreditCardTerminal' then 1
when 'Cash' then 2
when 'Check' then 3
when 'Billing' then 4
when 'GiftCard' then 5
when 'CreditCard' then 6
else 0
end
EOS

  end
end
