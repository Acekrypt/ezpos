

require 'singleton'
require 'inv/sale'

class SalesHistoryCtrl
    include Singleton


    def glade=( glade )
	@glade = glade

	@window       = glade.get_widget("returns_window")
	@sales_view   = glade.get_widget('sales_listing_view')
	@items_view   = glade.get_widget('sales_items_view')
	@subtotal_amt = glade.get_widget('sale_view_subtotal')
	@tax_amt      = glade.get_widget('sale_view_tax')
	@total_amt    = glade.get_widget('sale_view_total')
	@reason_dialog= glade.get_widget('return_reason_dialog')
	@reason_text  = glade.get_widget('reason_text_widget')
	@reason_info  = glade.get_widget('returns_reason_info')
	@print_button = glade.get_widget('print_receipt_button')

	glade.get_widget('back_to_sale_button').signal_connect('clicked') do
	    SalesHistoryCtrl.instance.hide
	end

	glade.get_widget('print_receipt_button').signal_connect('clicked') do
	    SalesHistoryCtrl.instance.print_receipt
	end

	@model = Gtk::ListStore.new(String,String,String,String )
	@sales_view.model=@model

	@sales_view.selection.mode = Gtk::SELECTION_SINGLE
 	@sales_view.headers_visible=true

	column = Gtk::TreeViewColumn.new("ID",Gtk::CellRendererText.new, {:text => 0})
 	column.min_width = 50
	@sales_view.append_column(column)

	column = Gtk::TreeViewColumn.new("Date",Gtk::CellRendererText.new, {:text => 1})
 	column.min_width = 150
	@sales_view.append_column(column)

	renderer = Gtk::CellRendererText.new
	renderer.xalign = 0.5
	column = Gtk::TreeViewColumn.new("Customer",renderer, {:text => 2})
 	column.min_width = 150
	column.alignment = 0.5
	@sales_view.append_column(column)

	renderer = Gtk::CellRendererText.new
  	renderer.xalign = 1
	column = Gtk::TreeViewColumn.new("Total",renderer, {:text => 3})
 	column.min_width = 100
	column.alignment = 1
	@sales_view.append_column(column)

	@items_grid=ViewItemGrid.new( @items_view,self )

	@calendar = glade.get_widget('returns_calendar_ctrl')
	@sale_id_box = glade.get_widget('returns_sale_id_entry_box')

	@sales_view.signal_connect('cursor_changed') do | view,row_num,col,store |
	    @sale_id_box.text=""
	    display_sale(  INV::Sale.new(  @sales_view.selection.selected.get_value( 0 ) ) )
 	end

	@sale_id_box.signal_connect('activate') do find_from_box end
	@calendar.signal_connect('day_selected') do
	    @sale_id_box.text=""
	    @items_grid.clear
	    update_sales
	end
    end

    def present
	@window.present
	@sale_id_box.grab_focus
	update_sales
    end

    def print_receipt
	Printer.instance.output_sale( @sale )
    end

    def hide
	@window.hide
    end

    def date
	Time.local( @calendar.date[0],@calendar.date[1],@calendar.date[2] )
    end

    def move_calendar( date )
	@calendar.select_month( date.month, date.year )
	@calendar.select_day( date.day )
    end

    def remove_sku( row )
	sku = row[ ItemsGrid::SKU_ELEMENT ]
	@reason_text.sensitive=true
	buffer = @reason_text.buffer
	buffer.delete( buffer.start_iter, buffer.end_iter )
	@items_grid.insert( sku )
	if Gtk::Dialog::RESPONSE_OK==@reason_dialog.run
	    sku.return( buffer.get_text )
	end
	@reason_dialog.hide
    end

    def row_selected( row )
	sku = row[ ItemsGrid::SKU_ELEMENT ]
	if sku.returned?
	    rec = sku.return_record
	    @reason_info.set_markup('Returned ' + rec.occured.strftime("%I:%M%p - ") + rec.occured.strftime("%m/%d/%Y") )
	    @reason_text.sensitive=false
	    buffer = @reason_text.buffer
	    buffer.delete( buffer.start_iter, buffer.end_iter )
	    buffer.insert( buffer.start_iter, rec.reason )
	    @reason_dialog.run
	    @reason_dialog.hide
	end
    end

    def find_from_box
	sales = update_sales
	if ! sales.empty?
	    sale = sales.first
	    move_calendar( sale.occured )
	    display_sale( sale )
	end
    end

    def display_sale( sale )
	set_items(sale)
	update_amounts( sale )
	@print_button.sensitive=true
	@sale=sale
    end

    def clear_sale
	@print_button.sensitive=false
	@sale=nil
	set_amount( @subtotal_amt, '0.00' )
	set_amount( @tax_amt, '0.00' )
	set_amount( @total_amt, '0.00' )
    end

    def set_amount( ctrl, amt )
	ctrl.set_markup( amt )
    end

    def update_amounts( sale )
	set_amount( @subtotal_amt, sale.formated_subtotal )
	set_amount( @tax_amt, sale.formated_tax )
	set_amount( @total_amt, sale.formated_total )
    end

    def set_items( sale )
	@items_grid.clear
	sale.skus.reverse.each{ | sku |
	    @items_grid.insert( sku )
	}

    end

    def update_sales
	if @sale_id_box.text.empty?
	    sales = INV::Sale.find_on_date( date ).reverse
	else
	    begin
		sales = Array[INV::Sale.new( @sale_id_box.text ) ]
	    rescue Exception
		sales = Array.new
		dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::ERROR,Gtk::MessageDialog::BUTTONS_CLOSE, 'Sale ID: ' + @sale_id_box.text + ' not found'  )
		dialog.default_response=Gtk::Dialog::RESPONSE_OK
		dialog.run
		dialog.destroy
		@sale_id_box.text = ""
	    end
	end
	set_sales( sales )
	sales
    end


    def set_sales( sales )
	@model.clear
	clear_sale
	for sale in sales
	    row = @model.append
	    row[0] = sale.db_pk.to_s
	    row[1] = sale.occured.strftime('%I:%M%P %m/%d/%y')
	    payment = sale.payment
	    if payment.payment_method.is_a? Payment::Method::BillingAcct
		row[2] = sale.customer.code
	    else
		row[2] = payment.payment_method.name
	    end
	    row[3] = sale.formated_total
	end

    end


end
