
require 'nas/payment'

require 'singleton'
#require 'nas/payment/credit_card/card'
require 'nas/payment/credit_card/yourpay'
require 'nas/widgets/get_string'

class PaymentCtrl

    include Singleton
    
    def glade=( glade )

	@payment_type_dialog=glade.get_widget("payment_type_dialog")
	@payment_type_dialog.default_response=Gtk::Dialog::RESPONSE_OK

	glade.get_widget('payment_type_ok_button').signal_connect('clicked') do on_payment_type_ok end
	glade.get_widget('payment_type_cancel_button').signal_connect('clicked') do on_payment_type_cancel end

	@payment_type_combo_box = glade.get_widget("payment_type_menu_ctrl")
	menu = Gtk::Menu.new
	for pt in NAS::Payment::Type.all
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
	rec = NAS::Payment.total( @payments )
	tot = @pending_sale.total
	@payment_type_label.set_markup( 'Sale Total: ' + tot.to_s + ' - ' + rec.to_s + ' = ' + (tot - rec).to_s + ' Remaining' )
	@payment_type_dialog.run
    end

    def on_payment_type_ok
	payment_type = NAS::Payment::Type.all[ @payment_type_combo_box.history ]
	@payment_type_dialog.hide
	if payment_type.is_a?( NAS::Payment::Method::CreditCard ) && POS::Setting.instance.process_cards
	    get_card_payment_info
	else
	    record_payment( payment_type )
	end
    end

    def get_card_payment_info
	recieved = Money.new( @pending_sale.total - NAS::Payment.total(@payments) )

	@amt_received.text = ( @pending_sale.total - NAS::Payment.total(@payments) ).to_s
	for child in @more_info_vbox.children
	    @more_info_vbox.remove(child)
	end
	@payment_info = Array.new
	
	label = Gtk::Label.new( 'Swipe Card or enter #' )
	@more_info_vbox.pack_start( label, true,true, 10 )
	label.show
	entry = Gtk::Entry.new
	entry.activates_default=true
	@payment_info.push( entry )
	@more_info_vbox.pack_start( entry, true,true, 0 )
	entry.show
	entry.grab_focus
	separator = Gtk::HSeparator.new
	@more_info_vbox.pack_start(separator)
	@payment_more_info_dialog.run
    end

    def on_payment_type_cancel
	@sale=nil
	@payment_type_dialog.hide
	clear_payments
    end

    def clear_payments
	if @payments
	    for p in @payments
		p.remove
	    end
	end
    end

    def record_payment( payment_type )
	@amt_received.text = ( @pending_sale.total - NAS::Payment.total(@payments) ).to_s
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
	payment_type = NAS::Payment::Type.all[ @payment_type_combo_box.history ]
	if payment_type.is_a?( NAS::Payment::Method::CreditCard ) && POS::Setting.instance.process_cards
	    process_credit_card_payment
	else
	    record_std_payment(payment_type)
	end
    end


    def record_std_payment(payment_type)
	    elements=Array.new
	    for el in @payment_info
		elements.push( el.text )
	    end
	    err_msg = payment_type.validate( elements )
	    if err_msg.empty?
		@customer=payment_type.get_customer( elements )
		
		@payments.push( NAS::Payment.new( Hash[ 
						     'method_id'=>payment_type.db_pk,
						     'amount'=> Money.new( @amt_received.text ),
						     'transaction_id'=>payment_type.transaction_id( elements ),
						 ] ) )
		if  NAS::Payment.total( @payments ) < @pending_sale.total
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

    def present_processing_dialog
	d=Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::INFO,Gtk::MessageDialog::BUTTONS_CANCEL, 'Now Processing Card' )
	d.signal_connect('response'){ | w |  }
	d.show_now
	d
    end

    def process_credit_card_payment
#	@payment_more_info_dialog.hide
	@customer=NAS::LocalConfig::Accounts.credit_card

	try_again=false
	cc=@payment_info.first.text
	match = /(\d+)=(\d{2})(\d{2})/.match(cc)
	results=nil
	if match
	    d=present_processing_dialog
	    results=YourPay.FaceToFaceCharge( Money.new( @amt_received.text ), match[1], match[3], match[2] )
	    d.destroy
	elsif cc == POS::Setting::BAD_CC_SWIPE
	    d=Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::ERROR,Gtk::MessageDialog::BUTTONS_OK,'Bad Swipe' )
     	    d.run
	    d.destroy
	    get_additional_payment
	else
	    str=cc.gsub(/\D/,'')
	    if /\d{16}/.match( str )
		month=NAS::Widgets::GetString.new('Date','Expiration Month' ).to_s
		year=NAS::Widgets::GetString.new('Date','Expiration Year' ).to_s
		if ! month.empty? && ! year.empty?
		    d=present_processing_dialog
		    results=YourPay.FaceToFaceCharge( Money.new( @amt_received.text ), cc, month, year )
		    d.destroy
		end
	    end
	end
	if results
	    results.each{ |k,v| puts "#{k.to_s} => #{v.to_s}" } if DEBUG

	    if results['approved'] == 'APPROVED'
		amt=Money.new( @amt_received.text )
		@payments.push( NAS::Payment.new( Hash[ 
						     'method_id'=> NAS::Payment::Method::CreditCard.new.db_pk,
						     'amount'=> amt,
						     'transaction_id'=> results['ordernum'],
						 ] ) )
		try_again= ( amt < @pending_sale.total )
	    else
		dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,
						Gtk::MessageDialog::ERROR,
						Gtk::MessageDialog::BUTTONS_YES_NO,
						"The credit card did not procesess successfully.\n\n" <<
						"The returned message was:\n\n#{results['error']}\n#{results['message']}\nTry Again?" )
		try_again = ( dialog.run == Gtk::Dialog::RESPONSE_YES )
		dialog.destroy
	    end
	end
	@payment_info.clear
	
	get_additional_payment if try_again
    end

end
