class ReturnsPaymentType < ActiveRecord::Migration
  def self.up
      add_column 'pos_sale_sku_returns', 'payment_type', :text
  end

  def self.down
      remove_column 'pos_sale_sku_returns', 'payment_type'
  end
end
