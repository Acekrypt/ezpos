
require 'gconf2'
require 'customer'

module Globals
    @check_account = @credit_card_account = @cash_account = Customer.find( 'CASH' )

    def Globals.init
	@gConf = GConf::Client.new
	@tax = @gConf["/apps/ezpos/tax_rate"]
	@print_header =	@gConf['/apps/ezpos/print_header']
	@print_header = "" if ! @print_header
	@tax=0.0 if ! @tax
	@taxExtemp = false;
    end

    def Globals.tax_rate=( tax )
	@gConf['/apps/ezpos/tax_rate'] = tax
	@tax = tax
	TotalsDisplay.instance.update
    end

    def Globals.tax_rate
	@tax
    end

    def Globals.tax_exempt=( val )
	@taxExtemp = val
    end

    def Globals.tax_exempt
	@taxExtemp
    end

    def Globals.toggle_tax_exempt
	@taxExtemp = ! @taxExtemp
    end


    def Globals.CreditCardAccount
	@credit_card_account
    end

    def Globals.CashAccount
	@cash_account
    end

    def Globals.CheckAccount
	@check_account
    end

    def Globals.customer
	@cash_account
    end

    def Globals.printHeader
	@print_header
    end

    def Globals.printHeader=( ph )
	@gConf['/apps/ezpos/print_header'] = ph
	@print_header = ph
    end
end
