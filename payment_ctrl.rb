
require 'payment'

require 'singleton'


class PaymentCtrl

    include Singleton
    
    def glade=( glade )

	@payment_type_dialog=glade.get_widget("payment_type_dialog")
	@payment_type_dialog.default_response=Gtk::Dialog::RESPONSE_OK

	glade.get_widget('payment_type_ok_button').signal_connect('clicked') do on_payment_type_ok end
	glade.get_widget('payment_type_cancel_button').signal_connect('clicked') do on_payment_type_cancel end

	@payment_type_combo_box = glade.get_widget("payment_type_menu_ctrl")
	menu = Gtk::Menu.new
	for pt in Payment::Type.all
	    menu.append( Gtk::MenuItem.new( pt.name ) )
	end
	menu.show_all
	@payment_type_combo_box.menu = menu

	@more_info_vbox = glade.get_widget('payment_more_info_box')

	@payment_type_label=glade.get_widget('payment_type_label')

	@amt_received=glade.get_widget('payment_more_info_amount_received')

	@payment_more_info_dialog = glade.get_widget("payment_more_info_dialog")
	@payment_more_info_dialog.default_response=Gtk::Dialog::RESPONSE_OK

	glade.get_widget('payment_more_info_ok_button').signal_connect('clicked') do  on_payment_more_info_ok end
	glade.get_widget('payment_more_info_cancel_button').signal_connect('clicked') do  on_payment_more_info_cancel end
    end


    def record_sale( pending_sale )
	@pending_sale = pending_sale
	@sale = nil
	@payments=Array.new
	get_additional_payment

	if @payments.empty?
	    clear_payments
	    nil
	else
	    @pending_sale.record( @customer, @payments )
	end
    end

    def get_additional_payment
	rec = Payment.formated_total( @payments )
	tot = @pending_sale.formated_total
	@payment_type_label.set_markup( 'Sale Total: ' + tot + ' - ' + rec + ' = ' + sprintf('%.2f',tot.to_f - rec.to_f ) + ' Remaining' )
#	@amt_received.grab_focus
	@payment_type_dialog.run
    end

    def on_payment_type_ok
	payment_type = Payment::Type.all[ @payment_type_combo_box.history ]
	@payment_type_dialog.hide
	record_payment( payment_type )
    end

    def on_payment_type_cancel
	@sale=nil
	@payment_type_dialog.hide
	clear_payments
    end

    def clear_payments
	if @payments
	    for p in @payments
		p.destroy
	    end
	end
    end

    def record_payment( payment_type )
	@amt_received.text = sprintf('%.2f', @pending_sale.total - Payment.total(@payments) ) 

	for child in @more_info_vbox.children
	    @more_info_vbox.remove(child)
	end
	@payment_info = Array.new
	for question in payment_type.needs
	    label = Gtk::Label.new( question )
	    @more_info_vbox.pack_start( label, true,true, 10 )
	    label.show
	    entry = Gtk::Entry.new
	    entry.activates_default=true
	    @payment_info.push( entry )
	    @more_info_vbox.pack_start( entry, true,true, 0 )
	    entry.show
	    separator = Gtk::HSeparator.new
	    @more_info_vbox.pack_start(separator)
	end
	@payment_more_info_dialog.run
    end

    def on_payment_more_info_ok
	@payment_more_info_dialog.hide
	
	payment_type = Payment::Type.all[ @payment_type_combo_box.history ]
	elements=Array.new
	for el in @payment_info
	    elements.push( el.text )
	end
	err_msg = payment_type.validate( elements )
	if err_msg.empty?
	    @customer=payment_type.get_customer( elements )

	    @payments.push( Payment.new( Hash[ 
					    'method_id'=>payment_type.db_pk,
					    'customer_id'=> @customer.db_pk,
					    'amount'=> @amt_received.text.to_f,
					    'transaction_id'=>payment_type.transaction_id( elements ),
					] ) )
	    if  sprintf( '%.2f',Payment.total( @payments ) ).to_f < sprintf( '%.2f',@pending_sale.total).to_f
		get_additional_payment
	    end
	else
	    dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_CLOSE,err_msg )
	    dialog.run
	    dialog.destroy
	    get_additional_payment
	end
    end


    def on_payment_more_info_cancel
	@sale=nil
	@payment_more_info_dialog.hide
	clear_payments
    end
    

end
