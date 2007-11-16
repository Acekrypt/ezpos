class BigintPrice < ActiveRecord::Migration
  def self.up

      execute "ALTER TABLE skus ALTER COLUMN price type bigint"
  end

  def self.down
      execute "ALTER TABLE skus ALTER COLUMN price type int"
  end
end
