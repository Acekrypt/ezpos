

require 'singleton'

class TotalsDisplay
    include Singleton

    OPEN_MARKUP = '<span weight="bold" font_family="Terminal" foreground="red" size="xx-large"'
    MARKUP = OPEN_MARKUP + '>'

    def sale=( sale )
	@sale = sale
	update
    end

    def update
	@subtotal.set_markup( MARKUP + @sale.formated_subtotal + '</span>' )
	if ( POS::Setting.instance.tax_exempt )
#	    @sale.tax_rate = 0
	    @tax.set_markup( OPEN_MARKUP + ' strikethrough="true">0.00</span>' )
	else
#	    @sale.updatetax_rate = POS::Setting.instance.tax_rate
	    @tax.set_markup( OPEN_MARKUP + ' strikethrough="false">' + @sale.formated_tax + '</span>' )
	end
	@total.set_markup( MARKUP + @sale.formated_total + '</span>' )
    end

    def tax_exempt=( val )
	@taxExempt = val
	@tax_label.set_markup( OPEN_MARKUP + ' strikethrough="' + POS::Setting.instance.tax_exempt.to_s + '">Tax:</span>')
	update
    end

    def glade=( glade )
	glade.get_widget("subtotal_label").set_markup( MARKUP + 'SubTotal:</span>')
	glade.get_widget("total_label").set_markup( MARKUP + 'Total:</span>')
	@subtotal = glade.get_widget( "subtotal_amt" )
	@tax = glade.get_widget( "tax_amt" )
	@total = glade.get_widget("total_amt")
	@tax_label = glade.get_widget( "tax_label" )
	@tax_label.set_markup( MARKUP + 'Tax:</span>')
    end
end


