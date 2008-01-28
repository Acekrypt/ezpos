class CcVoids < ActiveRecord::Migration
  def self.up
      create_table :cc_voids do | t |
          t.string :auth_number
          t.datetime :voided_at
          t.integer  :sale_id
      end
  end

  def self.down
      drop_table :cc_voids
  end
end
