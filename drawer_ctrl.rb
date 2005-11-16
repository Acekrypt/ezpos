require 'singleton'


class Drawer

    include Singleton

    def initialize
	@cash = @check = @credit_card = 0.00
    end

    def add_cash( amount )
	@cash += amount
    end

    def add_check( amount )
	@check += amount
    end

    def add_credit_card( amount )
	@credit_card += amount
    end

    def cash_on_hand
	@cash
    end

    def check_on_hand
	@cash
    end

    def credit_receipts_on_hand
	@credit_card
    end

    def formatted_cash_on_hand
	sprintf( '.2f', cash_on_hand )
    end
    
    def formatted_checks_on_hand
	sprintf( '.2f', checks_on_hand )
    end

    def formatted_credit_receipts_on_hand
	sprintf( '.2f', credit_receipts_on_hand )
    end

    # BEL - Switches 1-3 ON Switches 4-8 OFF

    def open
        prn = Tempfile.new('Drawer-Open-')
#    	prn = File.new( NAS::LocalConfig::CASH_DRAWER_PORT,'w' )
        prn.putc 0x1B
        prn.putc 'p'
        prn.putc 0
        prn.putc 25
        prn.putc 250
        prn.close
        system("#{NAS::LocalConfig::CASH_DRAWER_COMMAND} #{prn.path}" )
    end

    
end
