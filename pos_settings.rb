require 'gconf2'

module POSSetting

    def POSSetting.init
	@gConf = GConf::Client.new
	@tax = @gConf['/apps/ezpos/tax_rate']
	@print_header =	@gConf['/apps/ezpos/print_header']
	@print_header = '' if ! @print_header
	@tax=0.0 if ! @tax
	@taxExtemp = false;
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

    def POSSetting.printHeader
	@print_header
    end

    def POSSetting.printHeader=( ph )
	@gConf['/apps/ezpos/print_header'] = ph
	@print_header = ph
    end
 
    def POSSetting.drawer_char
	7
    end

    
end
