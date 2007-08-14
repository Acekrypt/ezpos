require 'nas/ezpos/sku_grid'

module NAS

module EZPOS

class HistorySkuGrid < SkuGrid

    def initialize( parent )
        @parent=parent
        super
    end

    def first_col_pixbuf
        Gdk::Pixbuf.new( File.dirname( __FILE__ ) + '/return.png' )
    end

    def col_name( col )
        if col == 0
            return 'Ret'
        else
            return super( col )
        end
    end

    def editable?
        false
    end

    def remove( iter )
        if iter[ CODE ] == 'RETURN'
            dialog = Gtk::MessageDialog.new( nil,
                                             Gtk::Dialog::MODAL,
                                             Gtk::MessageDialog::ERROR,
                                             Gtk::MessageDialog::BUTTONS_OK,
                                             'Continuum Dysfunction! Item is already a return.' )
            dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
            dialog.run
            dialog.destroy
        else
            @parent.return_sku( iter[SKU] )
        end
    end

end


end # EZPOS

end # NAS
