class BarcoderView < ActiveRecord::Migration
    def self.up
        execute 'grant select on am_barcoder_items_view to barcoder'
    end

    def self.down

    end
end
