class BarcoderView < ActiveRecord::Migration
    def self.up
        begin
                execute 'create role barcoder'
        rescue PGError
        end
        execute 'grant select on am_barcoder_items_view to barcoder'
    end

    def self.down
        execute 'drop role barcoder'
    end
end
