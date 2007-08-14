class PaymentTypesRework < ActiveRecord::Migration
  def self.up
      execute 'alter table pos_payment_types drop column get_customer_func'
      execute 'alter table pos_payment_types drop column get_transaction_func'
      execute 'alter table pos_payment_types drop column validation_func'
      execute 'alter table pos_payment_types drop column needs'
      execute 'alter table pos_payment_types drop column should_open_drawer'
      execute 'alter table pos_payment_types add column type text'
      execute "update pos_payment_types set type='PosPaymentType::CreditCardTerminal' where id = 1"
      execute "update pos_payment_types set type='PosPaymentType::Cash' where id = 2"
      execute "update pos_payment_types set type='PosPaymentType::Check' where id = 3"
      execute "update pos_payment_types set type='PosPaymentType::BillingAccount' where id = 4"
      execute "update pos_payment_types set type='PosPaymentType::GiftCertificate' where id = 5"
      execute "update pos_payment_types set type='PosPaymentType::YourPayCreditCard' where id = 6"
  end

  def self.down
      execute 'alter table pos_payment_types add column get_customer_func text'
      execute 'alter table pos_payment_types add column get_transaction_func text'
      execute 'alter table pos_payment_types add column validation_func text'
      execute 'alter table pos_payment_types add column should_open_drawer boolean'
      execute 'alter table pos_payment_types add column needs text'
      execute 'alter table pos_payment_types drop column type'
  end

end
