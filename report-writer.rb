#!/usr/bin/ruby -I/usr/local/lib/rubylib


require 'pdf/ezwriter'
require 'inv/sale'
require 'www/cgi'
require 'payment'
require 'inv/sales_summary'
require 'inv/sale_sku_return'
require 'inv/sku_summary'
require 'daily_receipts'

pdf = PDF::EZWriter.new("Letter", :landscape)


pdf.select_font('pdf/fonts/Times-Roman')


date = Time.new - 86400

receipt = DailyReceipt.find_on_date( date )

pdf.ez_text( date.strftime('%d %b, %Y') + " Sales Report for\n" + LocalConfig::LOCATION_NAME + "\n\n",
            18, { :justification => :centre })

if receipt
    deposits=Array[ Array[ 'Type','Amount' ] ]
    deposits.push( Hash['Type'=>'Check','Amount'=>receipt.formated_checks ] )
    deposits.push( Hash['Type'=>'Cash','Amount'=>receipt.formated_cash ] )
    deposits.push( Hash['Type'=>'Credit Cards','Amount'=>receipt.formated_credit_cards ] )
    deposits.push( Hash['Type'=>'Total','Amount'=>receipt.formated_total ] )
    pdf.ez_table(deposits,{'Type'=>'Type','Amount'=>'Amount'},"Days Receipts",Hash[:fontSize=>14,:shaded=>0, :cols => Hash['Amount' => Hash[:justification => :right] ] ] )
else
    pdf.ez_text( "Day Was not closed out properly!\nNo End-of-Day totals were entered!\n",
		18, { :justification => :centre })
end

pdf.ez_set_dy( -30 )

sales=INV::Sale.find_on_date( date )

summary = INV::SalesSummary.new( sales )

returns_summary = INV::SKUSummary.new( Array.new )
returns =  INV::SaleSKUReturn.find_on_date( date )
for ret in returns
    returns_summary.add_sku( ret.sale_sku )
end

totals=Array[ Array[ 'Type','Amount' ] ]
totals.push( Hash['Type'=>'Check','Amount'=>summary.formated_amount_of_type( Payment::Method::Check) ] )
totals.push( Hash['Type'=>'Cash','Amount'=>summary.formated_amount_of_type( Payment::Method::Cash) ] )
totals.push( Hash['Type'=>'Credit Cards','Amount'=>summary.formated_amount_of_type( Payment::Method::CreditCard ) ] )
totals.push( Hash['Type'=>'Billing','Amount'=>summary.formated_amount_of_type( Payment::Method::BillingAcct ) ] )

totals.push( Hash['Type'=>'SubTotal','Amount'=>summary.formated_subtotal ] )

totals.push( Hash['Type'=>'Tax','Amount'=> summary.formated_tax_collected ] )

totals.push( Hash['Type'=>'Total','Amount'=>summary.formated_total ] )

totals.push( Hash['Type'=>'Returned','Amount'=>'-' + returns_summary.formated_subtotal ] )
totals.push( Hash['Type'=>'Returned Tax','Amount'=>'-' + returns_summary.formated_tax ] )

totals.push( Hash['Type'=>'Total','Amount'=> sprintf( '%.2f',( summary.total-returns_summary.total ) ) ] )


pdf.ez_table(totals,{'Type'=>'Type','Amount'=>'Amount'},"Program Recorded",Hash[:fontSize=>14,:shaded=>0, :cols => Hash['Amount' => Hash[:justification => :right] ] ])


pdf.ez_new_page

pdf.select_font('pdf/fonts/Courier')



def layout_sku( pdf, sku )
    pdf.ez_text( sprintf('%-15s%-65s%10s%10s%5s%10s%3s%10s',
			     sku.code,
			     WWW::CGI.unescape( sku.descrip ),
			     sku.um,
			     sku.formated_undiscounted_price,
			     sku.discount,
			     sku.formated_price,
			     sku.qty.to_s,
			     sku.formated_total
			 ),9 )
end


def layout_sale( pdf, sale )
      y_pos = pdf.ez_text( sprintf('<b>%-15s%-65s%10s%10s%7s%8s%4s%9s</b>',
				 'Code',
				 'Desc',
				 'U/M',
				 'Price',
				 'Disc',
				 'Price',
				 'Qty',
				 'Total'
				 ),9 )
    for sku in sale.skus
	y_pos = layout_sku( pdf, sku )
	if sku.returned?
	    pdf.set_line_style(1,nil,nil,[5])
	    pdf.line( 30, y_pos+4,730,y_pos+4)
	    pdf.set_line_style(1,nil,nil,[])
	end
    end

    pdf.line( 30, y_pos-5, 750, y_pos-5)
    pdf.ez_set_y( y_pos-5 )
    y_pos=pdf.ez_text( sprintf('<b>ID: %-5d Time: %-8s Account: %-8s SubTotal: %-15s Tax: %-15s Total: %-15s</b>',
			       sale.db_pk,
			       sale.occured.strftime('%I:%M%p'),
			       sale.customer.code,
			       sale.formated_subtotal,
			       sale.formated_tax,
			       sale.formated_total ) )
    payments = sale.payments
    if payments.size > 1
	for payment in payments
	    line =  sprintf('      <b>Payment: %-20s %10.2f',
				       payment.name_of,
				       payment.amtreceived )
	    line += '  REF# ' + payment.transaction_id if ( payment.transaction_id ) && ( ! payment.transaction_id.empty? )
	    line += '</b>'
	    y_pos=pdf.ez_text( line )
	end
    end

    pdf.ez_set_y( y_pos-15 )
end


for sale in sales
    page_num = pdf.ez_get_current_page_number
    pdf.start_transaction(:level)
    layout_sale( pdf, sale )
    if page_num != pdf.ez_get_current_page_number
	pdf.rewind_transaction(:level)
	pdf.ez_new_page
	layout_sale( pdf, sale )
    end
    pdf.commit_transaction(:level)
end


if ( ! returns.empty? )
    pdf.select_font('pdf/fonts/Times-Roman')
    pdf.ez_text( "Returned Items\n", 18, { :justification => :centre })
    pdf.select_font('pdf/fonts/Courier')
    for ret in returns
	sku = ret.sale_sku
	sale = sku.sale
	pdf.ez_text( 'Returned ' + ret.occured.strftime("%I:%M%p"), 9 )
	pdf.ez_text( 'Original Sale ID ' + sale.db_pk.to_s + ' @ ' + sale.occured.strftime("%m/%d/%Y at %I:%M%p") ,9 )
	pdf.ez_text( 'Reason   ' + ret.reason,9 )
	layout_sku( pdf, sku )
    end
end


output = pdf.ez_output

File.open("report.pdf", "wb") { |f| f << output }
