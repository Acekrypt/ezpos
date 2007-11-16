require 'nas/ezpos/settings'
require 'nas/ezpos/notebook'
require 'nas/ezpos/main_menu'
require 'nas/ezpos/daily_receipts_dialog'

module NAS
module EZPOS

class MainWindow < Gtk::Window

    def update
        @notebook.update
    end

    def initialize
        super(Gtk::Window::TOPLEVEL)
        set_title( 'EzPOS' )
        set_default_size( ::DEF::POS_HEIGHT, ::DEF::POS_WIDTH )
        resizable=true
        signal_connect('delete_event') do|widget,key|
              shutdown
        end
        if DEBUG
            signal_connect('key_press_event') do|widget,key|
                if key.keyval == 113
                    shutdown
                end
            end
        elsif DEF::FULL_SCREEN
            fullscreen
            set_has_frame( false )
        else
            maximize
        end

        @menu=MainMenu.new( self )

        main_box=Gtk::VBox.new
        main_box.pack_start( @menu, false, true, 0)

        @notebook=NoteBook.new( self )
        f12 = Gtk::AccelGroup.new
        f12.connect( Gdk::Keyval.const_get( :GDK_F12 ),nil, Gtk::ACCEL_VISIBLE ) {
            @notebook.finalize_sale
        }
        self.add_accel_group( f12 )

        main_box.pack_start( @notebook, true, true )

        add( main_box )

        self.show_all
    end

    def enter_deposits
        DailyReceiptsDialog.new( Date.today )
    end

    def shutdown
        @notebook.shutdown
        Gtk.main_quit
    end



end # MainWindow

end # EZPOS

end # NAS
