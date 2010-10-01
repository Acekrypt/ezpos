
require 'tempfile'

module NAS

module EZPOS

class ReceiptPrinter

    LINE='----------------------------------------'

    def ReceiptPrinter.print_signature_slip( sale )
        time = sale.occured.strftime("%I:%M%p - ") + sale.occured.strftime("%b %d %Y")
        recpt=Tempfile.new( 'pos-sale-' )
        name=`hostname`.chomp[0..8]
        recpt.puts sprintf('SALE #: %-6d%8s%18s',sale.id,name,time )
        recpt.puts LINE
        sale.payments.each do | payment |
            recpt.puts sprintf('%-25s%15s',payment.class.name.demodulize.titleize, payment.amount.format )
            recpt.puts 'X'*( 16-payment.cc_digits.length ) + payment.cc_digits unless payment.cc_digits.empty?
            recpt.puts sprintf('Auth: %-30s',payment.data ) unless payment.data.empty?
        end
        recpt.puts LINE
        output_skus( sale, recpt )
        recpt.puts LINE
        recpt.puts
        recpt.puts '  I agree to pay for the above item(s)'
        recpt.puts '  according to my cardholder agreement'
        recpt.puts
        recpt.puts
        recpt.puts
        recpt.puts
        recpt.puts
        recpt.puts '   ___________________________________'
        recpt.puts '                Signature'
        recpt.puts
        recpt.puts
        recpt.puts '                Thank You!'
        1.upto(8){ recpt.puts }

        # cut receipt
        recpt.putc 0x1B
        recpt.putc 'd'
        recpt.putc 5
        recpt.putc 0x1B
        recpt.putc 'm'

        recpt.close
        if DEBUG
            File.open(recpt.path){  |f| f.each_line{|l| STDERR.puts l } }
        else
            `lp -s -d #{DEF::RECEIPT_PRINTER} #{recpt.path}`
        end
    end

    def ReceiptPrinter.output_skus( sale, recpt )
        sale.skus.each do | sku |
            recpt.puts sku.descrip[0..39]
            if sku.discounted?
                line = sprintf('%-10s%3d x %0.2f',sku.code, sku.qty,sku.undiscounted_price )
                line+= ' - ' + sku.discount_percent.to_s + '% ='
                remainder = 40 - line.size
                if ( remainder < sku.total.to_s.size )
                    recpt.puts line
                    recpt.puts sprintf("%40.2f", sku.subtotal )
                else
                    recpt.puts sprintf("%s%#{remainder}.2f", line,sku.subtotal )
                end
            else
		if sku.qty > 1 
	                recpt.puts sprintf('%-14s%3d x %-8.2f%12.2f',sku.code, sku.qty, sku.price, sku.subtotal )
		else 
	                recpt.puts sprintf('%-14s%26.2f',sku.code, sku.subtotal )
		end
            end
        end
    end

    def ReceiptPrinter.print( sale )
        recpt=Tempfile.new( 'pos-sale-' )

        recpt.putc 0x1B
        recpt.putc 0x40

       # open drawer
#        recpt.putc 0x1B
#        recpt.putc 'p'
#        recpt.putc 0
#        recpt.putc 25
#        recpt.putc 250
        unless DEBUG
            File.open( RAILS_ROOT + "/db/" + DEF::RECEIPT_LOGO ) do | file |
                recpt.write file.read
            end
        end

        Settings['receipt_header'].each_line{ |line|
            line.chomp!
            recpt.puts line.center(40)
        }

        recpt.puts LINE
        time = sale.occured.strftime("%I:%M%p - ") + sale.occured.strftime("%b %d %Y")

        recpt.puts sprintf('SALE #: %-6d%26s',sale.id,time )
        recpt.puts LINE
        output_skus( sale, recpt )
        recpt.puts LINE
        if sale.discounted?
            recpt.puts sprintf('You Saved:%30s',sale.discount_amount.format )
            recpt.puts LINE
        end
        recpt.puts sprintf('Subtotal: %30s',sale.subtotal.format )
        recpt.puts sprintf('Tax:      %30s',sale.tax.format )
        recpt.puts sprintf('Total:    %30s',sale.total.format )
        recpt.puts LINE
        sale.payments.each do | payment |
            recpt.puts 'X'*( 16-payment.cc_digits.length ) + payment.cc_digits unless payment.cc_digits.empty?
            recpt.puts sprintf('Auth: %-30s',payment.data ) unless payment.data.empty?
        end
        recpt.puts 'Change'   + sprintf('%34s',sale.change_given.format )
        recpt.puts LINE
        Settings['receipt_footer'].each_line{ |line|
            line.chomp!
            recpt.puts line.center(40)
        }
#       1.upto(8){ recpt.puts }


        # cut receipt
        recpt.putc 0x1B
        recpt.putc 'd'
        recpt.putc 5
        recpt.putc 0x1B
        recpt.putc 'm'
        recpt.close

        if DEBUG
            File.open(recpt.path){  |f| f.each_line{|l| STDERR.puts l } }
        else
            `lp -s -d #{DEF::RECEIPT_PRINTER} #{recpt.path}`
        end

    end

end # ReceiptPrinter

end # EZPOS

end # NAS
