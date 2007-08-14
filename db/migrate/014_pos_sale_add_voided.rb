class PosSaleAddVoided < ActiveRecord::Migration
  def self.up
      add_column( :pos_sales, :voided, :boolean )
      add_column( :pos_sales, :void_reason, :text )
  end

  def self.down
      remove_column( :pos_sales, :voided )
      remove_column( :pos_sales, :void_reason )
  end
end
