
require 'tempfile'

module NAS

module EZPOS

class ReceiptPrinter

    LINE='----------------------------------------'

    def ReceiptPrinter.print_signature_slip( sale )
        time = sale.occured.strftime("%I:%M%p - ") + sale.occured.strftime("%b %d %Y")
        recpt=Tempfile.new( 'pos-sale-' )

        recpt.puts sprintf('SALE #: %-6d%26s',sale.id,time )
        recpt.puts LINE
        sale.payments.each do | payment |
            if payment.payment_type == PosPaymentType::CREDIT_CARD
                recpt.puts sprintf('%-25s%15s',payment.payment_type.name,payment.amount.format )
            end
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

        `lp -s -d #{DEF::RECEIPT_PRINTER} #{recpt.path}` unless DEBUG
    end

    def ReceiptPrinter.output_skus( sale, recpt )
        sale.skus.each do | sku |
            recpt.puts sku.descrip[0..39]
            if sku.discounted?
                line = sprintf('%-10s%3d x %s',sku.code, sku.qty,sku.undiscounted_price.to_s )
                line+= ' - ' + sku.discount_percent.to_s + '% ='
                remainder = 40 - line.size
                if ( remainder < sku.total.to_s.size )
                    recpt.puts line
                    recpt.puts sprintf("%40s", sku.subtotal.to_s )
                else
                    recpt.puts sprintf("%s%#{remainder}s", line,sku.subtotal.to_s )
                end
            else
                recpt.puts sprintf('%-14s',sku.code) +
                    sprintf('%3d', sku.qty ) + ' x ' +
                    sprintf('%-8s', sku.price.to_s ) +
                    sprintf('%12s', sku.subtotal.to_s )
            end
        end
    end

    def ReceiptPrinter.print( sale )
        recpt=Tempfile.new( 'pos-sale-' )

        recpt.putc 0x1B
        recpt.putc 0x40

        File.open( RAILS_ROOT + "/db/" + DEF::RECEIPT_LOGO ) do | file |
            recpt.write file.read
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
           recpt.puts sprintf('%-25s%15s',payment.payment_type.name,payment.amount.format )
        end
        recpt.puts 'Change'   + sprintf('%34s',sale.change_given.format )
        recpt.puts LINE
        Settings['receipt_footer'].each_line{ |line|
            line.chomp!
            recpt.puts line.center(40)
        }
#       1.upto(8){ recpt.puts }

        # open drawer
        recpt.putc 0x1B
        recpt.putc 'p'
        recpt.putc 0
        recpt.putc 25
        recpt.putc 250

        # cut receipt
        recpt.putc 0x1B
        recpt.putc 'd'
        recpt.putc 5
        recpt.putc 0x1B
        recpt.putc 'm'
        recpt.close
  #      `cat #{recpt.path}`

        `lp -s -d #{DEF::RECEIPT_PRINTER} #{recpt.path}` # unless DEBUG
    end

end # ReceiptPrinter

end # EZPOS

end # NAS
