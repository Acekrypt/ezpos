
require 'gconf2'
require 'customer'

module POSSetting


    def POSSetting.init
	@gConf = GConf::Client.new
	@tax = @gConf["/apps/ezpos/tax_rate"]
	@print_header =	@gConf['/apps/ezpos/print_header']
	@print_header = "" if ! @print_header
	@tax=0.0 if ! @tax
	@taxExtemp = false;
	@check_account = @credit_card_account = @cash_account = Customer.find( 'CASH' )
    end

    def POSSetting.tax_rate=( tax )
	@gConf['/apps/ezpos/tax_rate'] = tax
	@tax = tax
	TotalsDisplay.instance.update
    end

    def POSSetting.tax_rate
	@tax
    end

    def POSSetting.tax_exempt=( val )
	@taxExtemp = val
    end

    def POSSetting.tax_exempt
	@taxExtemp
    end

    def POSSetting.toggle_tax_exempt
	@taxExtemp = ! @taxExtemp
    end


    def POSSetting.CreditCardAccount
	@credit_card_account
    end

    def POSSetting.CashAccount
	@cash_account
    end

    def POSSetting.CheckAccount
	@check_account
    end

    def POSSetting.customer
	@cash_account
    end

    def POSSetting.printHeader
	@print_header
    end

    def POSSetting.printHeader=( ph )
	@gConf['/apps/ezpos/print_header'] = ph
	@print_header = ph
    end
end
