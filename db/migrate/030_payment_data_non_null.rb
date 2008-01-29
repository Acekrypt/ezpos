class PaymentDataNonNull < ActiveRecord::Migration
  def self.up
      execute 'update pos_payments set data = \'\' where data is null'
      execute 'alter table pos_payments alter column data set default \'\''
      execute 'alter table pos_payments alter column data set not null'

      execute 'update pos_payments set cc_digits = \'\' where cc_digits is null'
      execute 'alter table pos_payments alter column cc_digits set default \'\''
      execute 'alter table pos_payments alter column cc_digits set not null'

  end

  def self.down
      execute 'alter table pos_payments alter column data drop not null'
      execute 'alter table pos_payments alter column cc_digits drop not null'
  end
end
