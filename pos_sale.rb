

require 'db'
require 'inv/pending_sale'
require 'drawer_ctrl'
require 'customer_info_dialog'
require 'printer'
require 'display_pole'

class PosSale


   

    def initialize
	@sale=INV::PendingSale.new( POS::Setting.instance.tax_rate )
	TotalsDisplay.instance.sale = @sale
	SaleItemsGrid.instance.clear

	FindItemsCtrl.instance.new_sale( self )
	SaleItemsGrid.instance.new_sale( self )
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
	dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_CLOSE,code + ' NOT FOUND' )
	dialog.default_response=Gtk::Dialog::RESPONSE_OK
	dialog.run
	dialog.destroy
    end

    def discount=( percent )
	SaleItemsGrid.instance.discount=percent
	update
    end

    def empty?
	SaleItemsGrid.instance.empty?
    end

    def add_skus( skus )
	if skus.empty?
	    false
	else
	    for sku in skus
		DisplayPole.instance.show_sku( sku )
		@sale.add_sku( sku )
		SaleItemsGrid.instance.insert( sku )
	    end
	    true
	end
    end

    def finalize( glade )
	return self if @sale.empty?
	pay_ctrl = PaymentCtrl.instance

	DB.instance.begin_transaction
	finalized_sale = pay_ctrl.save( @sale )

	glade.get_widget('discount_spin_ctrl').value=0
	SaleItemsGrid.instance.discount=0

	if ! finalized_sale
	    dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_CLOSE,'Unable to save sale')
	    dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
	    dialog.run
	    dialog.destroy
	    DB.instance.abort_transaction
	    return self
	end

	DisplayPole.instance.show_sale( finalized_sale )

	#print
	payment = finalized_sale.payment

	if payment.payment_method.is_a?( Payment::Method::Cash )
	    dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::INFO,Gtk::MessageDialog::BUTTONS_CLOSE,'Change Due: ' + sprintf('%.2f',payment.change_given ) )
	    dialog.signal_connect('response') do |widget, data|
		widget.destroy
	    end
	    dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
	    dialog.show
	end

	if payment.payment_method.is_a?( Payment::Method::BillingAcct )
	    cid = CustomerInfoDialog.new( glade, finalized_sale.customer )
	    cid.display
	end

	if payment.payment_method.open_drawer
	    Drawer.instance.open
	end

	Printer.instance.output_sale( finalized_sale )

	DB.instance.commit_transaction

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
	if add_skus( INV::SKU.find(code, false ) )
	    FindItemsCtrl.instance.clear
	else
	    code = FindItemsCtrl.instance.nearest_match
	    if add_skus( INV::SKU.find(code, false ) )
		FindItemsCtrl.instance.clear
	    else
		not_found( code)
	    end
	end
	TotalsDisplay.instance.sale = @sale
    end


end
