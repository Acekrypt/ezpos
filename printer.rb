require 'singleton'
require 'inv/sale'
require 'pos_settings'

class Printer
    include Singleton
    LINE='----------------------------------------'

    def output_sale( sale )

	recpt = Tempfile.new('ezpos-sale-'+sale.db_pk.to_s+'-')

	POS::Setting.instance.print_header.each_line{ |line|
	    line.chomp!
	    recpt.puts line.center(40)
	}

	recpt.puts LINE
	time = sale.occured.strftime("%I:%M%p - ") + sale.occured.strftime("%m/%d/%Y")
	recpt.puts sprintf('SALE #: %-6d%26s',sale.db_pk,time )
	recpt.puts LINE
	for sku in sale.skus
	    recpt.puts sku.descrip[0..39]
	    if 0 == sku.discount
		recpt.puts sprintf('%-14s',sku.code) + sprintf('%3d', sku.qty ) + ' x ' + sprintf('%-8.2f', sku.price ) + sprintf('%12.2f', sku.total )
	    else
		line =  sprintf('%-10s%3d x %.2f',sku.code, sku.qty,( sku.price + sku.discount ))
		line+= ' - ' +  sprintf('%.2f Disc',sku.discount)
		remainder = 40 - line.size
		if ( remainder < sprintf('%.2f',sku.total ).size )
		    recpt.puts line
		    recpt.puts sprintf("%40.2f", sku.total )
		else
		    recpt.puts sprintf("%s%#{remainder}.2f", line,sku.total )
		end
	    end
	end
	
	recpt.puts LINE
	recpt.puts 'Subtotal' + sprintf('%32.2f',sale.subtotal )
	recpt.puts 'Tax'      + sprintf('%37.2f',sale.tax )
	recpt.puts 'Total'    + sprintf('%35.2f',sale.total )
	recpt.puts LINE
	for payment in sale.payments
	    recpt.puts sprintf('%-25s%15.2f',payment.payment_method.name,payment.amtreceived )
	end
	
	recpt.puts 'Change'   + sprintf('%34.2f',sale.change_given )

	recpt.puts LINE
	recpt.puts '             Thank You!'
	recpt.puts
	recpt.puts
	recpt.puts
	recpt.puts
	recpt.puts
	recpt.puts
	recpt.puts
	recpt.puts
	recpt.puts
	recpt.close

       	system('lp -d receipt ' + recpt.path )

	f = File.new( recpt.path )
	f.each{ | line | puts line }
	f.close

    end

end

