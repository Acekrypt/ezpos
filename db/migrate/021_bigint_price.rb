class BigintPrice < ActiveRecord::Migration
  def self.up
      execute 'drop view am_barcoder_items_view'
      execute "ALTER TABLE skus ALTER COLUMN price type bigint"
      execute 'create view am_barcoder_items_view as select skus.code AS item_id, skus.descrip AS extended_desc, skus.price from skus'
  end

  def self.down
      execute 'drop view am_barcoder_items_view'
      execute "ALTER TABLE skus ALTER COLUMN price type int"
      execute 'create view am_barcoder_items_view as select skus.code AS item_id, skus.descrip AS extended_desc, skus.price from skus'
  end
end
