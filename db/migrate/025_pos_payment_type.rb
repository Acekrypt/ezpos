class PosPaymentType < ActiveRecord::Migration
  def self.up
      `sudo apt-get install libgpgme-ruby -y`

      add_column 'pos_payments', 'type', :text
      add_column 'pos_payments', 'post_processed', :boolean, :default=>'f'
      execute <<EOS;
update pos_payments set type = case pos_payment_type_id
when 1 then 'PosPayment::CCTerminal'
when 2 then 'PosPayment::Cash'
when 3 then 'PosPayment::Check'
when 4 then 'PosPayment::Billing'
when 5 then 'PosPayment::GiftCard'
when 6 then 'PosPayment::YourPay'
else 'UNK'
end
EOS
      execute 'update pos_payments set post_processed=\'t\',transaction_id= substr(transaction_id,5) where pos_payment_type_id=6 and transaction_id like \'XXX-%\''

      remove_column 'pos_payments', 'pos_payment_type_id'
      rename_column 'pos_payments', 'transaction_id', 'data'
  end

  def self.down
      rename_column 'pos_payments',  'data','transaction_id'
      add_column 'pos_payments', 'pos_payment_type_id', :int
      execute <<EOS;
update pos_payments set pos_payment_type_id = case type
when 'PosPayment::CCTerminal' then 1
when 'PosPayment::Cash' then 2
when 'PosPayment::Check' then 3
when 'PosPayment::Billing' then 4
when 'PosPayment::GiftCard' then 5
when 'PosPayment::YourPay' then 6
else 0
end
EOS

      execute 'update pos_payments set transaction_id = \'XXX-\' || transaction_id where post_processed = \'t\''
      remove_column  'pos_payments', 'post_processed'
      remove_column 'pos_payments', 'type'
  end

end

__END__

UPDATE pos_payments set pos_payment_type_id = 6 where pos_payment_type_id = 1;
UPDATE pos_payments set transaction_id = 'XXX-' || transaction_id where pos_payment_type_id = 6;
