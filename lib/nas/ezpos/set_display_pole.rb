module NAS

module EZPOS

class SetDisplayPole < Gtk::Dialog


    def initialize( parent )
        super('Display Pole Messages',parent, Gtk::Dialog::MODAL )

        welcome=Gtk::Frame.new('Welcome Message:')

        self.vbox.pack_start( welcome, false, true, 5 )

        vb=Gtk::VBox.new
        hbox=Gtk::HBox.new
        vb.add( hbox )

        welcome.add( vb )

        hbox.pack_start( Gtk::Label.new('Pause '), false )
        welcome_pause=Gtk::Entry.new
        welcome_pause.xalign=0.5
        hbox.pack_start( welcome_pause, false )
        hbox.pack_start( Gtk::Label.new(' Seconds'), false )
        welcome_pause.width_chars=5


        welcome_line_one=Gtk::Entry.new
        vb.pack_start( welcome_line_one, false, true, 5 )

        welcome_line_two=Gtk::Entry.new
        vb.pack_start( welcome_line_two,false, true, 5 )


        thanks=Gtk::Frame.new('Thanks Message:')
        thanks.shadow_type=Gtk::SHADOW_IN

        self.vbox.pack_start( thanks, false, true, 5 )

        vb=Gtk::VBox.new
        hbox=Gtk::HBox.new
        vb.add( hbox )

        thanks.add( vb )

        hbox.pack_start( Gtk::Label.new('Pause '), false )
        thanks_pause=Gtk::Entry.new
        thanks_pause.xalign=0.5
        thanks_pause.width_chars=5
        hbox.pack_start( thanks_pause, false )
        hbox.pack_start( Gtk::Label.new(' Seconds'), false )

        thanks_line_one=Gtk::Entry.new
        vb.pack_start( thanks_line_one,false, true, 5 )

        thanks_line_two=Gtk::Entry.new
        vb.pack_start( thanks_line_two,false, true, 5 )


        welcome_pause.text = Settings['display_pole/welcome_pause'].to_s
        thanks_pause.text = Settings['display_pole/thanks_pause'].to_s
        thanks_line_one.text=Settings['display_pole/thanks_line_one'].to_s
        thanks_line_two.text=Settings['display_pole/thanks_line_two'].to_s
        welcome_line_one.text=Settings['display_pole/welcome_line_one'].to_s
        welcome_line_two.text=Settings['display_pole/welcome_line_two'].to_s

        self.add_button( Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL )
        self.add_button( Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT )

        show_all

        self.run do | response |
            case response
            when Gtk::Dialog::RESPONSE_ACCEPT
                @ok=true
                Settings['display_pole/welcome_pause']=welcome_pause.text.to_i
                Settings['display_pole/thanks_pause']=thanks_pause.text.to_i
                Settings['display_pole/thanks_line_one']=thanks_line_one.text
                Settings['display_pole/thanks_line_two']=thanks_line_two.text
                Settings['display_pole/welcome_line_one']=welcome_line_one.text
                Settings['display_pole/welcome_line_two']=welcome_line_two.text
            else
                @ok=false
            end
            self.destroy
        end


    end

    def ok?
        @ok
    end

end # SetDisplayPole

end # EZPOS

end # NAS
