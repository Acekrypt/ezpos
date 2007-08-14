require 'nas/widgets/sku_finder'

module NAS

module Widgets

class GetText < Gtk::Dialog

    def initialize( title, label,value=nil,align=Gtk::JUSTIFY_LEFT,x=200,y=150 )
        super()

        @ok=false

        self.title = title
        self.modal=true
        @text = ''
        @label = Gtk::Label.new( label )
        @entry = Gtk::TextView.new
        @entry.buffer.text=value.to_s

        @entry.width_request=x
        @entry.height_request=y
        @entry.justification=align
        self.vbox.pack_start( @label,true,true,0  )

        sw=Gtk::ScrolledWindow.new
        sw.add( @entry )
        sw.set_policy( Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC )
        self.vbox.pack_start( sw ,true,true,0  )

        self.add_button(Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL )

        self.add_button(Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK )

        self.set_default_response(Gtk::Dialog::RESPONSE_OK)

        alt_s = Gtk::AccelGroup.new
        alt_s.connect( Gdk::Keyval::GDK_S, Gdk::Window::MOD1_MASK, Gtk::ACCEL_VISIBLE) {
            @entry.grab_focus
        }
        self.add_accel_group( alt_s )

        self.signal_connect("response") do | widget, response |
            case response
            when Gtk::Dialog::RESPONSE_OK
                @ok=true
                @text = @entry.buffer.text
            end
        end
        self.show_all
    end


    def text
        @text
    end

    def to_s
        @text
    end

    def ok?
        @ok
    end

end # class GetString

end # module Widgets

end # module NAS
