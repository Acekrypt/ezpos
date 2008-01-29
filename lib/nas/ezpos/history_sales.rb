
module NAS

module EZPOS

class HistorySales < Gtk::TreeView


    def initialize( history )
        @history=history
        super()

        self.model=Gtk::ListStore.new(Integer,String,String,String )

        self.selection.mode = Gtk::SELECTION_SINGLE
        self.headers_visible=true

        renderer = Gtk::CellRendererPixbuf.new
        renderer.pixbuf=Gdk::Pixbuf.new( File.dirname( __FILE__ ) + '/del.png' )
        column = Gtk::TreeViewColumn.new( 'Void',renderer )
        column.min_width = 20
        self.append_column(column)

        column = Gtk::TreeViewColumn.new("ID",Gtk::CellRendererText.new, {:text => 0})
        column.min_width = 50
        self.append_column(column)

        column = Gtk::TreeViewColumn.new("Time",Gtk::CellRendererText.new, {:text => 1})
#        column.min_width = 150
        self.append_column(column)

        renderer = Gtk::CellRendererText.new
        renderer.xalign = 0.5
        column = Gtk::TreeViewColumn.new("Type",renderer, {:text => 2})
        column.min_width = 150
        column.alignment = 0.5
        self.append_column(column)

        renderer = Gtk::CellRendererText.new
        renderer.xalign = 1
        column = Gtk::TreeViewColumn.new("Total",renderer, {:text => 3})
        column.min_width = 100
        column.alignment = 1
        self.append_column(column)

        self.signal_connect('row_activated') do | view,row_num,col,store |
            if 20 == col.min_width
                self.void(  self.model.get_iter( self.selection.selected.path ) )
            end
        end

        self.signal_connect('cursor_changed') do | view,row_num,col,store |
            @history.display_sale( PosSale.find(  self.selection.selected.get_value( 0 ).to_i ) )
        end
    end

    def each_iter
        iter = model.iter_first
        if iter
            yield iter
            while iter.next!
                yield iter
            end
        end
    end

    def highlite( sale )
        each_iter do | iter |
            if iter[ 0 ] == sale.id
                self.set_cursor( iter.path, nil, false )
                break
            end
        end
    end

    def void( iter )
        self.model.remove( iter ) if @history.void_sale( PosSale.find( iter[ 0 ] ) )
    end

    def update( date )
        self.model.clear
        sales = PosSale.find_on_date( date ).reverse
        sales.each do | sale |
            next if sale.voided?
            row = self.model.append
            row[0] = sale.id
            row[1] = sale.occured.strftime('%I:%M%P')
            row[2] = sale.paid_by
            row[3] = sale.total.to_s
        end
    end


end # HistorySales

end # EZPOS

end # NAS
