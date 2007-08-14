require 'nas/ezpos/sku_grid'

module NAS

module EZPOS

class SaleSkuGrid < SkuGrid

    def initialize( parent )
        @parent_widget=parent
        super( parent )
        self.signal_connect('key_press_event') do|widget,key|
            iter=self.selection.selected
            if iter
                case key.keyval
                when 65535 # delete
                    self.remove( iter )
                when 65451 # +
                    iter[ QTY ] += 1
		    update_sku( iter )
		    parent.update
                when 65453 # -
                    iter[ QTY ] -= 1
		    update_sku( iter )
		    parent.update
                when 65450 # *
                    self.set_cursor( iter.path, self.columns[ PRICE+1 ], true )
                when 65455 # /
                    self.set_cursor( iter.path, self.columns[ DESC+1 ], true )
                end
            end
        end
    end


    def first_col_pixbuf
        Gdk::Pixbuf.new( File.dirname( __FILE__ ) + '/del.png' )
    end

    def col_name( col )
        if col == 0
            return 'Rm'
        else
            return super( col )
        end
    end

    def editable?
        true
    end

    def cell_edited(cell, path_string, new_text, model)
        super( cell,path_string,new_text,model)
        @parent_widget.set_focus
    end
end

end # EZPOS

end # NAS
