

require 'nas/ezpos/sales_summary'
require 'nas/spreadsheet/excel'

module NAS

    module EZPOS

        class SalesPDF < NAS::PDF
            def draw_cell( txt, column_num )
                if column_num == 2 || column_num == 3 || column_num == 5
                    super( txt.to_s,column_num,'C' )
                else
                    super( txt,column_num )
                end
            end
        end

        class SalesReport

            attr_reader :summary

            def title
                'Sales Report for ' + DEF::LOCATION_NAME
            end

            def initialize( begining, ending=nil )
                @summary=SalesSummary.new( begining, ending )
            end

            def suggested_file_name
                if @summary.single_day?
                    @summary.begining.strftime('%b %d %Y')
                else
                    "#{@summary.begining.strftime('%b %d %Y')} - #{@summary.ending.strftime('%b %d %Y')}"
                end
            end

            def html
                ret=<<EOT
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">
            <title>#{@summary.date_str} #{title}</title>
  </head>
  <body text="#000000" bgcolor="#ffffff">
    <center>
      <h3>#{@summary.total_sales.format} Total Sales<br>#{@summary.date_str} #{title}</h3>
      <table width="100%">
        <tr>
            <td align="center" valign="top">
              <strong>#{@summary.date_str} Receipts</strong>
EOT
                if @summary.have_receipts?
                    ret+=<<-_EOT
                    <table border="1">
                        <tr><th>Type</th><th>Amount</th></tr>
                        <tr><td>Check</td><td align="right">#{@summary.check_receipts.format}</td></tr>
                        <tr><td>Cash</td><td align="right">#{@summary.cash_receipts.format}</td></tr>
                        <tr><td>Returns</td><td align="right">#{@summary.return_receipts.format}</td></tr>
                        <tr><td>Billing</td><td align="right">#{@summary.billing_receipts.format}</td></tr>
                        <tr><td>Credit Cards</td><td align="right">#{@summary.credit_card_receipts.format}</td></tr>
              </table>
                        _EOT
                else
                    ret+="<br>No Totals entered"
                end

                ret+=<<EOT
            </td>
            <td align="center" valign="top">
              <strong>Point of Sale Record for #{@summary.date_str}</strong>
              <table border="1">
                  <tr><th>Type</th><th>Amount</th></tr>
                  <tr><td>Check</td><td align="right">#{@summary.total_checks.format}</td></tr>
                  <tr><td>Cash</td><td align="right">#{@summary.total_cash.format}</td></tr>
                  <tr><td>Credit Cards</td><td align="right">#{@summary.total_credit_cards.format}</td></tr>
                  <tr><td>Billing</td><td align="right">#{@summary.total_billing.format}</td></tr>
                  <tr><td>Gift Certificate</td><td align="right">#{@summary.total_gift_cert.format}</td></tr>
                  <tr><td>SubTotal</td><td align="right">#{@summary.subtotal.format}</td></tr>
                  <tr><td>Tax</td><td align="right">#{@summary.tax_collected.format}</td></tr>
                  <tr><td>Total</td><td align="right">#{@summary.total.format}</td></tr>
                  <tr><td>Returned</td><td align="right">-#{@summary.returned_total.format}</td></tr>
                  <tr><td>Returned Tax</td><td align="right">-#{@summary.returned_tax.format}</td></tr>
                  <tr><td>Total</td><td align="right">#{@summary.total_sales.format}</td></tr>
              </table>
            </td>
          </tr>
      </table>
    </center>
  </body>
</html>
EOT
                return ret
            end

            def xls( file )
                workbook = Spreadsheet::Excel.new( file )
                ws=workbook.add_worksheet( "#{suggested_file_name}" )
                format = workbook.add_format
                ws.format_column( 1, 20, format )
                ws.format_column( 2, 18, format )
                ws.format_column( 3, 18, format )
                ws.format_column( 4, 60, format )
                ws.format_column( 13, 60, format )
                y=0
                ws.write( 0, 0, Array[ 'Sale','Rep','Time','Code', 'Description', 'UM', 'List Price','% Disc','Disc','Price', 'Qty', 'Tax', 'SubTotal','Payment' ] )
                @summary.sales.each do | sale |
                    sale.skus.each do | sku |
                        ws.write( y+=1, 0, Array[ sale.id, sale.rep, sale.occured.strftime("%Y-%m-%d %H:%M"), sku.code, sku.descrip, sku.uom, sku.undiscounted_price.to_s, sku.discount_percent,sku.discount.to_s, sku.price.to_s, sku.qty, sku.tax.to_s, sku.total.to_s ] )
                        unless sale.payments.empty?
                            tps=sale.payments.first.name
                            if sale.payments.size > 1
                                tps  << "-" << sale.payments.first.amount.format
                            end
                            sale.payments[1..sale.payments.size].each do | pay |
                                tps << ', ' << (pay.name+'-'+pay.amount.format)
                            end
                            ws.write( y, 13, tps )
                        end
                    end
                end
                workbook.close
            end

            def pdf( filename=nil )
                pdf=SalesPDF.new

                pdf.AddPage
                pdf.AddBookMark( 'Totals' )
                pdf.SetXLargeFont
                pdf.Cell( 0, 6, @summary.date_str, 0, 1, 'C' )
                pdf.Cell( 0, 6, title, 0, 1, 'C' )
                pdf.SetLargeFont
                pdf.Ln
                if @summary.have_receipts?
                    pdf.Cell( 0, 5,'Receipts',0,1,'C')
                    coll=Array[
                               [ 'Check', @summary.check_receipts ],
                               [ 'Cash', @summary.cash_receipts ],
                               [ 'Returns', @summary.return_receipts ],
                               [ 'Billing', @summary.billing_receipts ],
                               [ 'Credit Cards', @summary.credit_card_receipts ],
                               [ 'Total Amount', @summary.total_receipts ]
                             ]
                    pdf.SetX( 65 )
                    pdf.DrawTable( ['Type','Amount'],[50,30],coll )
                else
                    pdf.Cell(  0, 5,"Day Was not closed out properly!",0,1,'C')
                    pdf.Cell(  0, 5,"No End-of-Day totals were entered!",0,1,'C')
                end
                pdf.Ln
                pdf.Cell( 0, 5,'Recorded',0,1,'C')
                coll=Array[
                           [ 'Check', @summary.total_checks ],
                           [ 'Cash', @summary.total_cash ],
                           [ 'Credit Cards', @summary.total_credit_cards ],
                           [ 'Billing', @summary.total_billing ],
                           [ 'Gift Certificate', @summary.total_gift_cert ],
                           [ 'Subtotal',@summary.subtotal ],
                           [ 'Tax', @summary.tax_collected ],
                           [ 'Total', @summary.total ],
                           [ 'Returned', @summary.returned_total ],
                           [ 'Returned Tax', @summary.returned_tax ],
                           [ 'Total Amount', @summary.total_sales ],
                          ]
                pdf.SetX( 65 )
                pdf.DrawTable( ['Type','Amount'],[50,30],coll )

                pdf.AddPage
                pdf.AddBookMark( 'Sales' )
                pdf.SetFixedFont
                @summary.sales.each do | sale |
                    pdf_layout_sale( pdf, sale )
                end

                if ! @summary.returns.empty?
                    pdf.AddPage
                    pdf.AddBookMark( 'Returns' )
                    coll=Array.new
                    pdf.Cell(0,5,'Returns', 0, 1, 'C' )
                    pdf.Ln
                    @summary.returns.each{ | ret |
                        sku = ret.sku
                        sale = sku.sale
                        pdf.Cell( 20,5,'Reason:', 1, 0, 'L' )
                        pdf.Cell( 130,5, ret.reason, 'RTBL', 0,'L' )
                        pdf.Cell( 30,5, ret.payment_type, 'TBR', 1, 'R' )
                        pdf.Cell( 15,5,'Ret: ', 'TBL', 0, 'L' )
                        pdf.Cell( 35,5,ret.occured.strftime('%I:%M%p %Y-%m-%d'), 'TBR', 0, 'R' )
                        pdf.Cell( 20,5,'Orig Sale: ', 'TBL', 0, 'L' )
                        pdf.Cell( 80,5, "#{sale.id} #{sale.occured.strftime('%I:%M%p %Y-%m-%d')}", 'TBR', 0, 'R' )
                        pdf.Cell( 5,5, "Tax: ",'TBL', 0, 0, 'L' )
                        pdf.Cell( 25,5, sku.tax.format, 'TBR', 1, 'R' )
                        pdf.Cell( 25,5, sku.code, 1, 0, 'L' )
                        pdf.Cell( 125,5, sku.descrip, 'TBR',0,'L' )
                        pdf.Cell( 5,5, "Amt: ",'TBL', 0, 0, 'L' )
                        pdf.Cell( 25,5, sku.total.format, 'TBR', 1, 'R' )

                        pdf.Ln
                    }
                end
                pdf.Output( filename )
            end

            def pdf_layout_sale( pdf, sale )
                pdf.SetStdFont
                tbl=Array.new
                sale.skus.each{ | sku | tbl.push( Array[ sku.code, sku.descrip, sku.uom, sku.qty, sku.undiscounted_price, sku.discount_percent, sku.price, sku.total ] ) }
                pdf.DrawTable( ['Code','Description','U/M','Qty','Price','Disc %','Price','Total'],[ 25,95,10,8,15,18,15,17 ], tbl )
                pdf.SetX( 20 )
                pdf.SetLargeFont
                pdf.Cell( 20, 5, sale.id.to_s, 1, 0,'C' )
                pdf.Cell( 40, 5, sale.occured.strftime('%I:%M%p %Y-%m-%d'), 1, 0,'C' )
                pdf.Cell( 10, 5, 'Rep:', 'TBL', 0, 'L' )
                pdf.Cell( 25, 5, sale.rep, 'TBR', 0, 'C' )
                pdf.Cell( 10, 5, 'Tax: ', 'TBL', 0, 'L' )
                pdf.Cell( 20, 5, sale.tax.format, 'TBR', 0, 'R' )
                pdf.Cell( 10, 5, 'Total: ', 'TBL', 0, 'L' )
                pdf.Cell( 45, 5, sale.total.format, 'TBR', 1, 'R' )
                sale.payments.each do | payment |
                    pdf.SetX( 20 )
                    pdf.Cell( 20, 5, 'REF#', 'TBL', 0,'L' )
                    pdf.Cell( 50, 5, payment.transaction_id, 'TBR', 0,'C' )

                    pdf.Cell( 25, 5, payment.name, 'TBL', 0,'L' )
                    pdf.Cell( 30, 5, payment.amount.format, 'TBR', 0,'R' )
                    pdf.Cell( 25, 5, 'Chng:', 'TBL', 0,'L' )
                    pdf.Cell( 30, 5, sale.change_given.format, 'TBR', 1, 'R' )
                end
                pdf.SetX( 0 )
                pdf.SetY( pdf.GetY + 5 )
            end


        end # SalesReport

    end # EZPOS

end # NAS


