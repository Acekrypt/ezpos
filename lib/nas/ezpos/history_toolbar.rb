module NAS

module EZPOS

class HistoryToolbar < Gtk::Toolbar

    def initialize( parent )
        @parent=parent
        super()

        self.append( "Print Reciept", "Re-print reciept for current sale." ) {
            self.print
        }

    end


    def print
        @parent.print
    end

end # SaleToolbar

end # EZPOS

end # NAS

