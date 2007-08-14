class PosDailyReceipt < ActiveRecord::Migration
  def self.up
      create_table :pos_daily_receipts do | table |
          table.column :day, :date
          table.column :checks, :integer
          table.column :cash, :integer
          table.column :credit_cards, :integer
      end
      add_index :pos_daily_receipts, :day, :unique
  end

  def self.down
      drop_table :pos_daily_receipts
  end
end
