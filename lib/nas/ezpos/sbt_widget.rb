require 'vte'

module NAS

module EZPOS

class SbtWidget < Gtk::VBox

    def initialize
        super

        @term=Vte::Terminal.new

        @term.set_size( 80,25 )
        @term.set_font("Monospace 12", Vte::TerminalAntiAlias::FORCE_ENABLE )

        @restart=true
        self.pack_start(Gtk::Label.new, true,true )
        @term.signal_connect('child-exited'){
            @restart=true
        }

        @term.signal_connect('key_press_event') do|widget,key|
            self.exec if @restart
        end

        hb=Gtk::HBox.new
        hb.pack_start( Gtk::Label.new, true,true )
        hb.pack_start( @term, false, false )
        hb.pack_start( Gtk::Label.new, true,true )

        self.pack_start( hb, false, false )

        self.pack_start(Gtk::Label.new, true,true )
    end


    def exec
        @pid=@term.fork_command( './exec-sbt', Array['sbt' ],nil, File.dirname(__FILE__),false,false  )
        @restart=false
    end


    def down

    end


end

end # EZPOS

end # NAS
