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
num=Fixnum
num=0

pdf.ez_start_page_numbers(500, 28, 10,nil,nil,num )

pdf.select_font('pdf/fonts/Times-Roman')


date = Time.at( 1083619396 )

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
    pdf.ez_text( "Day Was not closed out properly!\nNo Deposit information was given!\n",
		18, { :justification => :centre })
end

pdf.ez_set_dy( -30 )

sales=INV::Sale.find_on_date( date )

summary = INV::SalesSummary.new( sales )

returns_summary = INV::SKUSummary.new( INV::SaleSKUReturn.find_on_date( date ) )

totals=Array[ Array[ 'Type','Amount' ] ]
totals.push( Hash['Type'=>'Check','Amount'=>summary.formated_amount_of_type( Payment::Method::Check) ] )
totals.push( Hash['Type'=>'Cash','Amount'=>summary.formated_amount_of_type( Payment::Method::Cash) ] )
totals.push( Hash['Type'=>'Credit Cards','Amount'=>summary.formated_amount_of_type( Payment::Method::CreditCard ) ] )
totals.push( Hash['Type'=>'Billing','Amount'=>summary.formated_amount_of_type( Payment::Method::BillingAcct ) ] )
totals.push( Hash['Type'=>'Tax','Amount'=> summary.formated_tax_collected ] )
totals.push( Hash['Type'=>'SubTotal','Amount'=>summary.formated_total_amount ] )
totals.push( Hash['Type'=>'Returned','Amount'=>'-' + returns_summary.formated_total_amount ] )
totals.push( Hash['Type'=>'Total','Amount'=> sprintf( '%.2f',( summary.total_amount-returns_summary.total_amount ) ) ] )






pdf.ez_table(totals,{'Type'=>'Type','Amount'=>'Amount'},"Program Recorded",Hash[:fontSize=>14,:shaded=>0, :cols => Hash['Amount' => Hash[:justification => :right] ] ])


pdf.ez_new_page

pdf.select_font('pdf/fonts/Courier')

def layout_sale( pdf, sale )
      y_pos = pdf.ez_text( sprintf('<b>%-15s%-65s%10s%10s%5s%10s%4s%9s</b>',
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
	y_pos = pdf.ez_text( sprintf('%-15s%-65s%10s%10s%5s%10s%3s%10s',
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

    pdf.line( 30, y_pos-5, 750, y_pos-5)
    pdf.ez_set_y( y_pos-5 )
    y_pos=pdf.ez_text( sprintf('<b>ID: %-5d Time: %-8s Account: %-8s Method: %-15s SubTotal: %-15s Tax: %-15s Total: %-15s</b>',
			       sale.db_pk,
			       sale.occured.strftime('%I:%M%p'),
			       sale.customer.code,
			       sale.payment.payment_method.name,
			       sale.formated_subtotal,
			       sale.formated_tax,
			       sale.formated_total ) )

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

 


output = pdf.ez_output

File.open("report.pdf", "wb") { |f| f << output }
