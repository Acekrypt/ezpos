

require 'db'
require 'inv/pending_sale'

class PosSale


    LINE='----------------------------------------'

    def initialize
	@sale=INV::PendingSale.new( Globals.tax_rate )
	TotalsDisplay.instance.sale = @sale
	ItemsGrid.instance.clear

	FindItemsCtrl.instance.new_sale( self )
	ItemsGrid.instance.new_sale( self )
    end

    def update
	@sale.clear
	@total = 0.0
	for sku in ItemsGrid.instance.skus
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
	dialog.run
	dialog.destroy
    end

    def discount=( percent )
	ItemsGrid.instance.discount=percent
	update
    end

    def empty?
	ItemsGrid.instance.empty?
    end

    def add_skus( skus )
	if skus.empty?
	    false
	else
	    for sku in skus
		@sale.add_sku( INV::SaleSKU.new( sku ) )
		ItemsGrid.instance.insert( sku )
	    end
	    true
	end
    end

    def finalize( glade )
	return self if @sale.empty?
	pay_ctrl = PaymentCtrl.instance
	finalized_sale = pay_ctrl.save( @sale )
	
	if finalized_sale
	    #print
	    payment = finalized_sale.payment

	    if payment.payment_method.is_a?( Payment::Method::Cash )
		dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::INFO,Gtk::MessageDialog::BUTTONS_CLOSE,'Change Due: ' + sprintf('%.2f',payment.change_given ) )
		dialog.signal_connect('response') do |widget, data|
		    widget.destroy
		end
		dialog.show
	    end

	    recpt = Tempfile.new('ezpos-sale-'+finalized_sale.db_pk.to_s+'-')

	    Globals.printHeader.each_line{ |line|
		line.chomp!
		recpt.puts line.center(40)
	    }


	    recpt.puts LINE
	    
	    for sku in @sale.skus
		recpt.puts sku.descrip[0..39]
		
		if 0 == sku.discount
		    recpt.puts sprintf('%-14s',sku.code) + sprintf('%3d', sku.qty ) + ' x ' + sprintf('%-8.2f', sku.price ) + sprintf('%12.2f', sku.subtotal )
		else
		    line =  sprintf('%-10s%3d x %.2f',sku.code, sku.qty,( sku.price + sku.discount ))
		    line+= ' - ' +  sprintf('%.2f Disc',sku.discount)
		    remainder = 40 - line.size
		    if ( remainder < sprintf('%.2f',sku.subtotal ).size )
			recpt.puts line
			recpt.puts sprintf("%40.2f", sku.subtotal )
		    else
			recpt.puts sprintf("%s%#{remainder}.2f", line,sku.subtotal )
		    end
		end
	    end
	  
	    recpt.puts LINE
	    recpt.puts 'Subtotal' + sprintf('%32.2f',@sale.subtotal )
	    recpt.puts 'Tax'      + sprintf('%37.2f',@sale.tax )
	    recpt.puts 'Total'    + sprintf('%35.2f',@sale.total )
	    recpt.puts LINE
	    recpt.puts sprintf('%-25s%15.2f',payment.payment_method.name,payment.amtreceived )
	    recpt.puts 'Change'   + sprintf('%34.2f',payment.change_given )
	    recpt.puts LINE
	    recpt.puts '             Thank You!'
	    recpt.close
	    dump = File.new( recpt.path )
	    dump.each {|line| puts line }

	    PosSale.new
	else
	    dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_CLOSE,'Unable to save sale')
	    dialog.run
	    dialog.destroy
	    self
	end
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
