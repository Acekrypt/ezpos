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
	char = POSSetting.drawer_char
	fork do
	    port = File.new( '/dev/lp0','w' )
	    port.putc char
	    port.close
	end
    end

    
end
