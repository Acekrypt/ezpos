
require 'payment'

require 'singleton'


class PaymentCtrl

    include Singleton



    def glade=( glade )
	@glade=glade
	@payment=nil
	@payment_info_dialog=glade.get_widget("payment_type_dialog")
	@payment_info_dialog.default_response=Gtk::Dialog::RESPONSE_OK
	@payment_more_info_dialog = glade.get_widget("payment_more_info_dialog")
	@payment_more_info_dialog.default_response=Gtk::Dialog::RESPONSE_OK
	@glade.get_widget('amt_received_dialog').default_response=Gtk::Dialog::RESPONSE_OK


	@more_info_vbox = glade.get_widget("payment_more_info_box")

	@combo_box = glade.get_widget("payment_type_menu_ctrl")

	glade.get_widget('payment_dialog_ok_button').signal_connect('clicked') do
 	    on_payment_ok
 	end
	glade.get_widget('payment_dialog_cancel_button').signal_connect('clicked') do
 	    on_payment_cancel
 	end

	glade.get_widget('on_amount_received_dialog_ok').signal_connect('clicked') do
	    on_amount_received_dialog_ok
 	end

	glade.get_widget('payment_more_info_ok_button').signal_connect('clicked') do
	    on_payment_more_info_ok
	end
	glade.get_widget('payment_more_info_cancel_button').signal_connect('clicked') do
	    on_payment_more_info_cancel
	end
	
#	@combo_box.set_value_in_list(true,false)
	menu = Gtk::Menu.new

	for pt in Payment::Type.all
	    menu.append(Gtk::MenuItem.new( pt.name ))
	end
	menu.show_all
	@combo_box.menu = menu


    end

    def on_amount_received_dialog_ok
	payment_type = Payment::Type.all[ @combo_box.history ]
	ctrl = @glade.get_widget('amount_recieved_dialog_text_ctrl')
	text_label = @glade.get_widget('amount_received_text_ctrl')
	if ctrl.text.to_f < @pending_sale.total
	    text_label.set_markup('<span weight="bold" foreground="red" size="large">Amount Entered less than Sale Total</span>')
	    @glade.get_widget('amt_received_dialog').run
	else
	    text_label.set_markup('<span weight="normal" size="large">Enter Amount Received</span>')
	    @sale = record_sale( @pending_sale, payment_type, payment_type.default_account, ctrl.text.to_f )
	    @glade.get_widget('amt_received_dialog').hide
	end
    end


    def on_payment_ok

	payment_type = Payment::Type.all[ @combo_box.history ]

	@payment_info_dialog.hide
	
	@payment_info = Array.new
	@payment_info.push( payment_type )

	if payment_type.needs.empty?
	    if payment_type.is_a? Payment::Method::Cash
		dialog = @glade.get_widget('amt_received_dialog').run
	    else
		@sale = record_sale(  @pending_sale, payment_type, payment_type.default_account, @pending_sale.total )
	    end
	else
	    @sale = nil
	    for child in @more_info_vbox.children
		@more_info_vbox.remove(child)
	    end
	    for question in payment_type.needs
		label = Gtk::Label.new( question )
		@more_info_vbox.pack_start( label, true,true, 10 )
		label.show
		entry = Gtk::Entry.new
		@payment_info.push( entry )
		@more_info_vbox.pack_start( entry, true,true, 0 )
		entry.show
		separator = Gtk::HSeparator.new
		@more_info_vbox.pack_start(separator)
	    end
	    @payment_more_info_dialog.run
	end
    end


    def record_sale( pending_sale, payment_type, customer,amtreceived )
	payment = Payment.new( Hash[ 'subtotal'=>pending_sale.subtotal, 'tax'=>pending_sale.tax, 'method_id'=>payment_type.db_pk,'customer_id'=> customer.db_pk,'amtreceived'=> amtreceived ] )
	pending_sale.record( customer, payment )
    end


    def on_payment_more_info_ok

	@payment_more_info_dialog.hide
	@sale = nil
	payment = @payment_info.shift
	elements = Array.new
	for el in @payment_info
	    elements.push( el.text )
	end
	err_msg = payment.validate( elements )
	if ! err_msg.empty?
	    dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_CLOSE,err_msg )
	    dialog.run
	    dialog.destroy
	else
	    customer = payment.default_account
	    if ! customer
		customer = Customer.find( elements.first )
	    end
	    if payment.is_a? Payment::Method::Cash
		@glade.get_widget('amt_received_dialog').run
	    else
		@sale = record_sale(  @pending_sale, payment, customer, @pending_sale.total )
	    end
	end
    end

    def on_payment_more_info_cancel
	@sale = nil
	@payment_more_info_dialog.hide
	@payment=nil
    end

    def save( pending_sale )
	@pending_sale=pending_sale
	@payment_info_dialog.run
	@sale
    end


    def on_payment_cancel
	@sale = nil
	@payment=nil
	@payment_info_dialog.hide
    end

    

end
