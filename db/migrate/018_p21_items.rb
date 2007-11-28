class P21Items < ActiveRecord::Migration
  def self.up

      create_table :inv_mast, :id => false do |t|
          t.column :inv_mast_uid, :int
          t.column :item_id, :text
          t.column :descrip, :text
          t.column :uom, :text
          t.column :uom_size, :int
          t.column :price, :float
          t.column :cost, :float
          t.column :deleted_flag, :boolean
      end

      add_index :inv_mast, :inv_mast_uid

      rename_column :skus, :price1, :price

      rename_column :skus, :um, :uom
      rename_column :pos_sale_skus, :um, :uom

      add_column :skus, :uom_size, :integer
      add_column :skus, :deleted_flag, :boolean
      add_column :skus, :inv_mast_uid, :integer

      remove_column :skus, :cost
      execute "delete from skus"
      execute "ALTER TABLE skus ALTER COLUMN price set not null"

      add_column :skus, :cost, :integer, :null=>false

      add_index :skus, :inv_mast_uid

      remove_column :skus, :level1
      remove_column :skus, :price2
      remove_column :skus, :level2
      remove_column :skus, :price3
      remove_column :skus, :level3
      remove_column :skus, :price4
      remove_column :skus, :level4
      remove_column :skus, :price5
      remove_column :skus, :level5
      remove_column :skus, :price6
      remove_column :skus, :level6
      remove_column :skus, :webonly
      remove_column :skus, :on_hand
      remove_column :skus, :isbn
      remove_column :skus, :category

      execute 'create view am_barcoder_items_view as select skus.code AS item_id, skus.descrip AS extended_desc, skus.price from skus'

      execute "INSERT into skus ( id,code,descrip,uom,price,uom_size,deleted_flag,inv_mast_uid,cost ) values ( 1,'NON_EXISTANT', 'Item Does Not Exist ', 'EA',0,1,'f',0, 0 )"
      execute "INSERT into skus ( id,code,descrip,uom,price,uom_size,deleted_flag,inv_mast_uid,cost ) values ( 2,'RETURN', 'Returned ', 'EA',0,1,'f',0, 0 )"

  end

  def self.down
      drop_table :inv_mast

#      rename_column :skus, :item_id, :code
      rename_column :skus, :price, :price1
      rename_column :skus, :uom, :um
      remove_column :skus, :uom_size
      remove_column :skus, :deleted_flag
      remove_column :skus, :inv_mast_uid

      rename_column :pos_sale_skus, :uom, :um

      add_column :skus, :level1, :text
      add_column :skus, :price2, :integer
      add_column :skus, :level2, :text
      add_column :skus, :price3, :integer
      add_column :skus, :level3, :text
      add_column :skus, :price4, :integer
      add_column :skus, :level4, :text
      add_column :skus, :price5, :integer
      add_column :skus, :level5, :text
      add_column :skus, :price6, :integer
      add_column :skus, :level6, :text
      add_column :skus, :webonly, :boolean
      add_column :skus, :on_hand, :integer
      add_column :skus, :isbn, :text
      add_column :skus, :category, :text
  end
end
