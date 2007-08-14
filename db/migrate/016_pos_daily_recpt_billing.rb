class PosDailyRecptBilling < ActiveRecord::Migration
  def self.up
      add_column( :pos_daily_receipts, :billing, :integer )
      add_column( :pos_daily_receipts, :returns, :integer )
  end

  def self.down
      remove_column( :pos_daily_receipts, :billing )
      remove_column( :pos_daily_receipts, :returns )
  end
end
