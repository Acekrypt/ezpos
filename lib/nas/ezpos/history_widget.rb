require 'nas/ezpos/receipt_printer'
require 'nas/ezpos/history_sales'
require 'nas/ezpos/history_sku_grid'
require 'nas/ezpos/history_toolbar'

module NAS

module EZPOS

class HistoryWidget < Gtk::VBox
    MARKUP = '<span weight="bold" font_family="Times" foreground="red" size="large"'


    def initialize( app )
        @app=app
        super()

        @toolbar=HistoryToolbar.new( self )
        self.pack_start( @toolbar, false )

        hbox = Gtk::HBox.new
        self.pack_start( hbox, false )

        @cal=Gtk::Calendar.new
        @cal.signal_connect( 'day-selected' ){ | d | self.date_selected }
        vbox=Gtk::VBox.new

        hb=Gtk::HBox.new
        lb=Gtk::Label.new('Enter Sale ID or Select Date')
        lb.xalign=0
        hb.pack_start( lb )
        @sale_id=Gtk::Entry.new

        @sale_id.signal_connect('activate') do
            got_sale_id_query
        end

        @sale_id.xalign=1
        hb.pack_start( @sale_id )

        vbox.pack_start( hb )
        vbox.pack_start( @cal )

        hbox.pack_start( vbox, false )

        vbox=Gtk::VBox.new

        @sales=HistorySales.new( self )
        win=Gtk::ScrolledWindow.new
        win.width_request= ( DEF::POS_WIDTH == 800 ? 250 : 450 )
        win.hscrollbar_policy=Gtk::POLICY_NEVER
        win.vscrollbar_policy=Gtk::POLICY_AUTOMATIC
        win.add(@sales)
        @sales.height_request=200 #@cal.height_request

        vbox.pack_start( win, true , true )
        vbox.pack_start(totals_table,false)

        hbox.pack_start( vbox, true, true )

        @skus=HistorySkuGrid.new( self )
        win=Gtk::ScrolledWindow.new
        win.hscrollbar_policy=Gtk::POLICY_NEVER
        win.vscrollbar_policy=Gtk::POLICY_AUTOMATIC
        win.add(@skus)
        self.pack_start( win )

        self.date_selected
    end

    def return_sku( sku )
        qty=sku.qty
        if qty > 1
            gn=NAS::Widgets::GetNumber.new("Number?","Return Qty:", sku.qty )
            qty=gn.to_i
        end
        gs=NAS::Widgets::GetText.new("Reason?","Reason for Return:" )

        pt_box = Gtk::OptionMenu.new
        menu = Gtk::Menu.new
        for pt in PosPaymentType.all
            menu.append( Gtk::MenuItem.new( pt.name ) )
        end
        menu.show_all
        pt_box.menu = menu
        gs.vbox.pack_start( Gtk::Label.new('Payment Returned') )
        gs.vbox.pack_start( pt_box ,true,true,0  )
        gs.show_all
        gs.run
        if gs.ok?
            payment_type = PosPaymentType.all[ pt_box.history ]
            ( ret_sku, ret_rec )=sku.return( payment_type, qty, gs.to_s ) if gs.ok?
            @app.add_sku_to_sale( ret_sku ) # if ret_sku
        end
        gs.destroy
        self.display_sale( PosSale.find( @sale.id ) )
    end

    def void_sale( sale )
        if sale.occured.to_date != Time.now.to_date
            dialog = Gtk::MessageDialog.new( nil,
                                             Gtk::Dialog::MODAL,
                                             Gtk::MessageDialog::ERROR,
                                             Gtk::MessageDialog::BUTTONS_OK,
                                             "Sales can only be voided on the day they occured" )
            dialog.run
            dialog.destroy
            return false
        end
        gs=NAS::Widgets::GetText.new("Reason?","Reaso for voiding sale #{sale.id}" )
        gs.show_all
        gs.run
        ret=gs.ok?
        if ret
            sale.void( gs.to_s )
            sale.save
        end
        gs.destroy
        return ret;
    end

    def set_focus
        @sale_id.grab_focus
    end

    def print
        ReceiptPrinter.print( @sale ) if @sale
    end

    def create_label(text)
        label=Gtk::Label.new
        label.markup="#{MARKUP}>#{text}</span>"
        label.xalign=0
        #@labels.push( label )
        return label
    end

    def got_sale_id_query
        sale_id = @sale_id.text.to_i
        sale=PosSale.find_by_id( sale_id )
        if sale
            if sale.voided?
                dialog = Gtk::MessageDialog.new( nil,
                                                 Gtk::Dialog::MODAL,
                                                 Gtk::MessageDialog::ERROR,
                                                 Gtk::MessageDialog::BUTTONS_OK,
                                                 "Sale #{sale_id} has been voided" )
                dialog.run
                dialog.destroy
            end
            display_sale( sale )
            @cal.select_month( sale.occured.month, sale.occured.year )
            @sales.update( sale.occured )
            @sales.highlite( sale )
        else
            dialog = Gtk::MessageDialog.new( nil,
                                             Gtk::Dialog::MODAL,
                                             Gtk::MessageDialog::ERROR,
                                             Gtk::MessageDialog::BUTTONS_OK,
                                             "Sale #{sale_id} was not found" )
            dialog.run
            dialog.destroy
        end
        @sale_id.text=""
    end

    def display_sale( sale )
        @sale=sale
        @skus.clear
        sale.skus.each{ | s |
            @skus.insert( s )
        }
        @sub_total_amount.markup="#{MARKUP}>#{sale.subtotal.format}</span>"
        @tax_amount.markup="#{MARKUP}>#{sale.tax.format}</span>"
        @total_amount.markup="#{MARKUP}>#{sale.total.format}</span>"
    end

    def totals_table
        table=Gtk::Table.new(3,2)
        table.attach( create_label('Sub Total:'), 0, 1, 0, 1 )
        @sub_total_amount=create_label('0.00')
        @sub_total_amount.xalign=1
        table.attach( @sub_total_amount, 1, 2, 0, 1 )

        @tax_label=create_label('Tax:')
        table.attach( @tax_label, 0, 1, 1, 2 )
        @tax_amount=create_label('0.00')
        @tax_amount.xalign=1
        table.attach( @tax_amount, 1, 2, 1, 2 )

        table.attach( create_label('Total:'), 0, 1, 2, 3 )
        @total_amount=create_label('0.00')
        @total_amount.xalign=1
        table.attach( @total_amount, 1, 2, 2, 3 )
    end

    def update
        self.date_selected
        GC.start
    end

    def update_sku(sku)

    end

    def date_selected
        @sales.update( Time.mktime( *@cal.date ) )
        @skus.clear
        self.set_focus
    end


end # HistoryWidget

end # EZPOS

end # NAS
