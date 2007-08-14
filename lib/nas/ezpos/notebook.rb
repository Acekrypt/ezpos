require 'nas/ezpos/sale_widget'
require 'nas/ezpos/history_widget'

module NAS

module EZPOS

class NoteBook < Gtk::Notebook

    attr_reader :sale, :history

    def initialize( app )
        @app=app
        super()
        self.set_show_tabs(true)
        self.set_scrollable(true)
        self.set_tab_pos(Gtk::POS_TOP)
        self.set_border_width(0)
        self.set_show_tabs(true)
        self.set_scrollable(false)
        self.show_border=false
        @sale=SaleWidget.new( self )
        self.append_page( @sale, Gtk::Label.new( 'Sale' ) )
        @history=HistoryWidget.new( self )
        self.append_page( @history, Gtk::Label.new( 'History' ) )

        @sale.set_focus

        @old_page=2

        self.signal_connect( 'switch-page' ) do | widget, page, page_num |
            @old_page=page_num
            case page_num
            when 1
                @history.update
            end
        end
        self.show_all

#        self.page=2 if DEBUG
    end

    def finalize_sale
        @sale.finalize
    end

    def add_sku_to_sale( sku )
        @sale.add_sku( sku )
    end

    def update
        @sale.update
    end

    def shutdown

    end

end # NoteBook

end # EZPOS

end # NAS
