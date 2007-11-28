require 'nas/ezpos/settings'
require 'nas/ezpos/totals_table'
require 'nas/ezpos/sale_sku_grid'
require 'nas/ezpos/sale_toolbar'
require 'nas/ezpos/payment_select'
require 'nas/ezpos/credit_card_payment'
require 'nas/ezpos/receipt_printer'
require 'nas/ezpos/cash_drawer'
require 'nas/ezpos/display_pole'
require 'nas/ezpos/customer_info_dialog'


module NAS

module EZPOS

class SaleWidget < Gtk::VBox

    def new_pixmap(filename, window, background)
        pixmap, mask = Gdk::Pixmap::create_from_xpm(window, background, filename )
        wpixmap = Gtk::Image.new(pixmap, mask)
    end

    def initialize( app )
        @app=app
        super()
        @display_pole=DisplayPole.new( DEF::DISPLAY_POLE_PORT )
        @toolbar=SaleToolbar.new( self )
        self.pack_start( @toolbar, false )

        hbox = Gtk::HBox.new
        self.pack_start( hbox, false )

        @totals=TotalsTable.new( self )
        @totals.set_size_request( DEF::POS_WIDTH.to_f*0.34, 150 )

        hbox.pack_start( @totals )
        @sku_finder=NAS::Widgets::SkuFinder.new( self, DEF::POS_SHOW_COST )

        @sku_finder.width_request=450
# ( DEF::POS_WIDTH == 800 ? 350 : 450 )

        hbox.pack_start( @sku_finder,true,true )
        @grid=SaleSkuGrid.new( self )
        win=Gtk::ScrolledWindow.new
        win.hscrollbar_policy=Gtk::POLICY_NEVER
        win.vscrollbar_policy=Gtk::POLICY_AUTOMATIC
        win.add(@grid )
        self.pack_start( win )
        self.reset
        GC.start

        if DEBUG
            Sku.find(:all, :order => 'RANDOM()', :limit=>rand(5)+5 ).each do | sku |
                got_sku( sku )
            end
        end
        @toolbar.focus_rep
    end


    def reset
        @sale=PosSale.new
        @display_pole.show_welcome
        @totals.sale=@sale
        @grid.sale=@sale
        @sku_finder.clear
        @toolbar.focus_rep
    end

    def finalize
        return if @sale.skus.empty?

        @display_pole.show_sale( @sale )
        @sale.occured=Time.now
        @sale.rep=@toolbar.rep
        @toolbar.begin_new_sale

        (need_signature,payments,remaining)=get_payments
        return if payments.nil?

        if payments.empty?
            @sale.set_default_customer
            @sale.save
            if @sale.skus.find( :first, :conditions=>"code='RETURN'" )
                ps=PaymentSelect.new( @sale.total, remaining )
                if ps.ok?
                    ps.record( @sale )
                else
                    return
                end
            end
        else
            @sale.customer=payments.first.selected_type.customer
            payments.each{ | p | p.record( @sale ) }
        end
        @sale.save

        @display_pole.show_thanks
        ReceiptPrinter.print( @sale )

        open_drawer=false
        payments.each do | p |
            if p.selected_type.should_open_drawer?
                open_drawer=true
                break
            end
        end

        CashDrawer.open if open_drawer

        ReceiptPrinter.print_signature_slip( @sale ) if need_signature

        if remaining.round(2) < 0
            dialog = Gtk::MessageDialog.new( nil,
                                             Gtk::Dialog::MODAL,
                                             Gtk::MessageDialog::INFO,
                                             Gtk::MessageDialog::BUTTONS_CLOSE,
                                             'Change Due: ' + remaining.format )
            dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
            dialog.run
            dialog.destroy
        end

        self.reset
    end

    def get_payments
        payments=Array.new
        remaining=@sale.total
        need_signature=false
        while true # loop until we have it all paid

            while remaining.round(2) > 0 do
                ps=PaymentSelect.new( @sale.total, remaining )
                if ps.ok?
                    payments.push( ps )
                    remaining-=ps.amount
                else
                    return
                end
            end

            if remaining.round(2) <= 0
                bad_payments=Array.new
                payments.each do | payment |
                    if payment.selected_type == PosPaymentType::CREDIT_CARD
                        ccp=CreditCardPayment.new( payment )
                        if ccp.ok?
                            need_signature=true
                            payment.transaction_id=ccp.msg
                        else
                            dialog = Gtk::MessageDialog.new( nil,
                                                             Gtk::Dialog::MODAL,
                                                             Gtk::MessageDialog::ERROR,
                                                             Gtk::MessageDialog::BUTTONS_OK,
                                                             "Credit Card Failed to process.\nMsg Returned:\n#{ccp.msg}" )
                            dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
                            dialog.run
                            dialog.destroy
                            remaining+=payment.amount
                            bad_payments.push( payment )
                        end
                    end
                end
                bad_payments.each{ | p | payments.delete( p ) }
            end
            break if remaining.round(2) <= 0
        end
        return Array[ need_signature, payments, remaining ]
    end

    def tax_rate
        tax=Settings['tax_rate']
        if tax.nil?
            return tax=Settings['tax_rate']=0.0
        else
            return tax.to_f/100
        end
    end

    def shutdown
        @app.shutdown
    end

    def tax_exempt?
        @toolbar.tax_exempt?
    end

    def update_tax
        if self.tax_exempt?
                @sale.tax_rate=0
        else
                @sale.tax_rate=self.tax_rate
        end
        @grid.update
        self.update
    end

    def update
        @totals.update
    end

    def update_discount
        @grid.discount=@toolbar.discount
        self.update
    end

    def update_sku( sku )
        @display_pole.show_sku( sku, @sale.total )
    end

    def add_sku( sku )
        @sale.skus.push( sku )
        @grid.insert( sku )
        @display_pole.show_sku( sku, @sale.total )
        self.update
    end

    def got_sku( sku )
        s=PosSaleSku.from_sku( sku )
        s.tax_rate=self.tax_rate
        s.discount_percent=@toolbar.discount
        add_sku( s )
    end

    def set_focus
        @sku_finder.focus
    end


end # SalesWidget

end # POS

end # NAS
