

require 'nas/db'
require 'nas/inv/pending_sale'
require 'drawer_ctrl'
require 'customer_info_dialog'
require 'printer'
require 'display_pole'
require 'discount_ctrl'

class PosSale

    def initialize
	@sale=NAS::INV::PendingSale.new( POS::Setting.instance.tax_rate )
	TotalsDisplay.instance.sale = @sale
	SaleItemsGrid.instance.clear
	DisplayPole.instance.show_welcome
	FindItemsCtrl.instance.new_sale( self )
	SaleItemsGrid.instance.new_sale( self )
	DiscountCtrl.instance.sale=self
    end

    def update
	@sale.clear
	@total = 0.0
	for sku in SaleItemsGrid.instance.skus
	    @sale.add_sku( sku )
	end
	TotalsDisplay.instance.sale = @sale
    end

    def add
	add_sku( FindItemsCtrl.instance.code )
    end

    def not_found( code )
	code = '' if ! code
	FindItemsCtrl.instance.clear
	dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_CLOSE,code + ' NOT FOUND' )
	dialog.default_response=Gtk::Dialog::RESPONSE_OK
	dialog.run
	dialog.destroy
    end


    def empty?
	SaleItemsGrid.instance.empty?
    end

    def add_skus( skus )
	if skus.empty?
	    false
	else
	    for sku in skus
		@sale.add_sku( sku )
		DisplayPole.instance.show_sku( sku,@sale.total )
		SaleItemsGrid.instance.insert( sku )
	    end
	    true
	end
    end

    def finalize( glade )
	return self if @sale.empty?

	NAS::DB.instance.begin_transaction

	finalized_sale = PaymentCtrl.instance.record_sale(  @sale )
	
	if ! finalized_sale
# 	    dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_CLOSE,'Unable to save sale')
# 	    dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
# 	    dialog.run
# 	    dialog.destroy
	    NAS::DB.instance.abort_transaction
	    return self
	end

	DisplayPole.instance.show_sale( finalized_sale )

	#print
	payments = finalized_sale.payments
	change_shown = false
	for p in payments
	    if ( ! change_shown ) && ( p.payment_method.is_a?( NAS::Payment::Method::Cash ) )
		p.change=finalized_sale.change_given
		dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::INFO,Gtk::MessageDialog::BUTTONS_CLOSE,'Change Due: ' + finalized_sale.change_given.to_s )
		dialog.signal_connect('response') do |widget, data|   widget.destroy end
		dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
		dialog.show
		change_shown = true
	    end

	    if p.payment_method.is_a?( NAS::Payment::Method::BillingAcct )
		cid = CustomerInfoDialog.new( glade, finalized_sale.customer )
		if ! cid.sale_ok?
		    NAS::DB.instance.abort_transaction
		    return self
		end
	    end

	    Drawer.instance.open if p.payment_method.open_drawer

	end

	Printer.instance.output_sale( finalized_sale )

	NAS::DB.instance.commit_transaction

	command = './drive_pole '
	command += POS::Setting.instance.pole_thank_you_pause.to_s + ' '
	command += POS::Setting.instance.pole_welcome_pause.to_s + ' '
	command += '\''+ POS::Setting.instance.pole_thank_you_one.center( 20 ) + '\' '
	command += '\''+ POS::Setting.instance.pole_thank_you_two.center( 20 ) + '\' '
	command += '\''+ POS::Setting.instance.pole_welcome_one.center( 20 ) + '\' '
	command += '\''+ POS::Setting.instance.pole_welcome_two.center( 20 ) + '\'&'

	system( command )

	PosSale.new
    end



    def sale
	@sale
    end

    def add_sku( code )
	if add_skus( NAS::INV::SKU.find(code, false ) )
	    FindItemsCtrl.instance.clear
	else
	    code = FindItemsCtrl.instance.nearest_match
	    if add_skus( NAS::INV::SKU.find(code, false ) )
		FindItemsCtrl.instance.clear
	    else
		not_found( code)
	    end
	end
	TotalsDisplay.instance.sale = @sale
    end


end
