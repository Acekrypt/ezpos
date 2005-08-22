#!/usr/bin/ruby

require 'nas/db/update/skus'


class UpdateEZPOS < NAS::DB::Update::SKUS
    
    RENAME_COLS = Hash.new

    FILES = [ 
	[  '', 'arinvt','/mnt/pos-sync/arinvt01.dbf' ]
    ]

    def initialize
	super
	dbf = XBase.new( FILES.first.last )
	@num=(dbf.size+11).to_f
	@times=0.to_f
    end

    def inc_fraction_done
	@times+=1
	return ( @times / @num )
    end

    def files
	FILES
    end

    def export
	# noop
    end

    def get_files
	# noop
    end

    def unlink_temp_files
	# noop
    end

end # class EZPOS


