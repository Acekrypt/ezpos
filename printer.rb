require 'singleton'
require 'nas/inv/sale'
require 'pos_settings'

class Printer
    include Singleton
    LINE='----------------------------------------'


    def print_signature_slip( sale )
	recpt = File.open( NAS::LocalConfig::RECEIPT_PRINTER_PORT, 'w' )

	time = sale.occured.strftime("%I:%M%p - ") + sale.occured.strftime("%b %d %Y")

	recpt.puts sprintf('SALE #: %-6d%26s',sale.db_pk,time )
	recpt.puts LINE
	for payment in sale.payments
            if payment.payment_method.is_a? NAS::Payment::Method::CreditCard
                recpt.puts sprintf('%-25s%15s',payment.payment_method.name,payment.amount.to_s )
            end
	end
	recpt.puts LINE
        recpt.puts
        recpt.puts '     I agree to pay the above amount'
        recpt.puts '   according to my cardholder agreement'
        recpt.puts
        recpt.puts
        recpt.puts
        recpt.puts
        recpt.puts
        recpt.puts '   -------------------------------------'
        recpt.puts '                Signature'
        recpt.puts
        recpt.puts
	recpt.puts '                Thank You!'
        recpt.putc 0x1B
        recpt.putc 'd'
        recpt.putc 5
        recpt.putc 0x1B
        recpt.putc 'm'

        recpt.close
    end


    def output_sale( sale )
	recpt = File.open( NAS::LocalConfig::RECEIPT_PRINTER_PORT, 'w' )

	POS::Setting.instance.print_header.each_line{ |line|
	    line.chomp!
	    recpt.puts line.center(40)
	}

	recpt.puts LINE
	time = sale.occured.strftime("%I:%M%p - ") + sale.occured.strftime("%b %d %Y")

	recpt.puts sprintf('SALE #: %-6d%26s',sale.db_pk,time )
	recpt.puts LINE
	for sku in sale.skus
	    recpt.puts sku.descrip[0..39]
	    if 0 == sku.discount
		recpt.puts sprintf('%-14s',sku.code) + sprintf('%3d', sku.qty ) + ' x ' + sprintf('%-8s', sku.price.to_s ) + sprintf('%12s', sku.total.to_s )
	    else
		line = sprintf('%-10s%3d x %s',sku.code, sku.qty,sku.undiscounted_total.to_s )
		line+= ' - ' + sku.formated_discount.to_s + ' Disc'
		remainder = 40 - line.size
		if ( remainder < sku.total.to_s.size )
		    recpt.puts line
		    recpt.puts sprintf("%40s", sku.total.to_s )
		else
		    recpt.puts sprintf("%s%#{remainder}s", line,sku.total.to_s )
		end
	    end
	end

	recpt.puts LINE
	recpt.puts 'Subtotal' + sprintf('%32s',sale.subtotal.to_s )
	recpt.puts 'Tax'      + sprintf('%37s',sale.tax.to_s )
	recpt.puts 'Total'    + sprintf('%35s',sale.total.to_s )
	recpt.puts LINE
        for payment in sale.payments
           recpt.puts sprintf('%-25s%15s',payment.payment_method.name,payment.amount.to_s )
        end
        recpt.puts 'Change'   + sprintf('%34s',sale.change_given.to_s )
	recpt.puts LINE
	recpt.puts '             Thank You!'
        recpt.putc 0x1B
        recpt.putc 'd'
        recpt.putc 5
        recpt.putc 0x1B
        recpt.putc 'm'

	recpt.close

    end

end

