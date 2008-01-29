class CcDigits < ActiveRecord::Migration
  def self.up
      add_column 'pos_payments', 'cc_digits', :text
  end

  def self.down
      remove_column 'pos_payments', 'cc_digits'
  end
end
