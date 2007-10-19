class Bigdec < ActiveRecord::Migration
  def self.up
      `sudo apt-get install libbigdecimal-ruby`
  end

  def self.down
  end
end
