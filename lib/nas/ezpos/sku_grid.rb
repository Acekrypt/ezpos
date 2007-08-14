module NAS

module EZPOS

class CellRender < Gtk::CellRendererText
    attr_accessor :column
    def initialize( parent,model,column )
        super()
        @column = column
        self.editable = parent.editable?
        self.background = "pink"
        signal_connect('edited') do |*args|
            parent.cell_edited(*args.push(model))
        end

    end

end


class SkuGrid < Gtk::TreeView

    NAMES=['',"Item","Description","U/M","Price","Qty","TAX","SubTotal","Disc %","Total  "]

    ( CODE, DESC, UM, PRICE, QTY, TAX, SUB_TOTAL, DISC, TOTAL,  SKU, RETURNED ) = *( 0..10 )

    BACKGROUND_ELEMENT = 9

    def first_col_pixbuf
        raise 'Unimplemented in base class'
    end

    def clear
        self.model.clear
    end

    def col_name( col )
        NAMES[col ]
    end

    def editable?
        false
    end

    def selected( iter )
        # noop
    end

    def remove( iter )
        @sale.skus.delete( iter[SKU] )
        self.model.remove( iter )
        @parent_widget.update
    end

    def release_focus
        @parent_widget.set_focus
    end

    def sale=( sale )
        self.clear
        @sale=sale
    end

    def initialize( parent )
        super()
        @parent_widget=parent
        @last_discount=0
        self.enable_search=false
        self.model=Gtk::ListStore.new(String,String,String,String,Integer,String,String,Integer,String,Sku, TrueClass )
        self.rules_hint = true
        self.selection.mode = Gtk::SELECTION_SINGLE
        self.headers_visible=true

        renderer = Gtk::CellRendererPixbuf.new

        self.signal_connect('row_activated') do | view,row_num,col,store |
            if 20 == col.min_width
                remove(  self.model.get_iter( self.selection.selected.path ) )
            elsif self.editable?
                selected( self.model.get_iter( self.selection.selected.path ) )
            end
            release_focus
        end

        renderer.pixbuf=self.first_col_pixbuf
        column = Gtk::TreeViewColumn.new(col_name(0),renderer )
        column.min_width = 20
        self.append_column(column)

        s = DEF::POS_WIDTH < 1024 ? true : false

        add_column( CODE,     s ? 100:120,    0, false )
        add_column( DESC,     s ? 250:380,    0, (self.editable?&&true) )
        add_column( UM,       s ?  50:70,   0.5, (self.editable?&&true) )
        add_column( PRICE,    s ?  60:80,    1, (self.editable?&&true)  )
        add_column( QTY,      s ?  30:40,  0.5, (self.editable?&&true)  )
        add_column( DISC,             50,  0.5, (self.editable?&&true)  )
        add_column( SUB_TOTAL,s ?  80:100,    1, false )
        add_column( TAX,      s ?  50:60,    1, false )
        add_column( TOTAL,            10,    1, false )
    end

    def add_column( col_num, width, align, editable )
        renderer = CellRender.new( self, self.model, col_num )
        renderer.xalign = align
        renderer.editable=editable

        renderer.ellipsize=Pango::ELLIPSIZE_MIDDLE if col_num == DESC

        column = Gtk::TreeViewColumn.new(col_name( col_num+1),renderer,{:text => col_num, :background_set => RETURNED})

        column.max_width=column.min_width = width

        column.alignment = align
        self.append_column( column )
    end

    def discount=(discount)
        each_iter do | iter |
            if iter[ DISC ] == @last_discount
                iter[ DISC ]=discount
                update_sku( iter )
            end
        end
        @last_discount=discount

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

    def each
        each_iter{ | i | yield i[SKU] }
    end

    def total
        tot=Money.new( 0 )
        each{ | sku | tot+=sku.discounted_total }
        return tot
    end

    def cell_edited(cell, path_string, new_text, model)
        row = model.get_iter( Gtk::TreePath.new(path_string) )
        return if row.nil?
        should_update=true
        sku=row[SKU]
        case cell.column
        when PRICE
            row[PRICE] = sprintf('%.2f',new_text.to_f)
        when QTY
            row[QTY] = new_text.to_i
        when DISC
            disc=new_text.to_i
            row[DISC] = disc
        else
            should_update=false
            row[ cell.column ] = new_text
        end
        update_sku( row )
        if should_update
            @parent_widget.update
        end
    end

    def update
        self.each_iter do | iter |
            update_sku( iter )
        end
    end

    def update_sku( row )
        sku=row[ SKU ]
        sku.qty=row[ QTY ].to_i
        sku.discount_percent=row[DISC]
        sku.descrip=row[ DESC ]
        sku.uom = row[ UM ]
        sku.undiscounted_price=Money.new( row[PRICE].to_f*100 )
        row[ TAX ] = sku.tax.to_s
        row[ SUB_TOTAL ] = sku.subtotal.to_s
        row[ TOTAL ] = sku.total.to_s
        @parent_widget.update_sku(sku)
    end

    def insert( sku )
        iter = model.insert_before( model.iter_first )
        iter[ SKU ]=sku
        iter[ CODE  ] = sku.code
        iter[ DESC  ] = sku.descrip
        iter[ UM    ] = sku.uom
        iter[ PRICE ] = sku.undiscounted_price.to_s
        iter[ QTY   ] = sku.qty
        iter[ DISC      ] = sku.discount_percent
        iter[ TAX       ] = sku.tax.to_s
        iter[ SUB_TOTAL ] = sku.subtotal.to_s
        iter[ TOTAL     ] = sku.total.to_s
        iter[ RETURNED  ] = sku.returned?
        self.scroll_to_cell( iter.path,nil,false,0,0 )
    end


end # SkuGrid

end # EZPOS

end # NAS
