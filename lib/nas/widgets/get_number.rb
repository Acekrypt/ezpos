require 'nas/widgets/sku_finder'

module NAS

module Widgets

class GetNumber
    
    def initialize( title, label, value=nil )

	@ok=false

	@dialog = Gtk::Dialog.new
	@dialog.title = title
	@dialog.modal=true
	@text = ''
	@label = Gtk::Label.new( label )
	@entry = Gtk::Entry.new
        @entry.xalign=1
	@entry.text=value.to_s if value
	@entry.activates_default=true

	alt_s = Gtk::AccelGroup.new
	alt_s.connect( Gdk::Keyval::GDK_S, Gdk::Window::MOD1_MASK, Gtk::ACCEL_VISIBLE) {
	    @entry.grab_focus
	}
	@dialog.add_accel_group( alt_s )

	@entry.signal_connect('insert-text') do | ent, char,b,c |
	    if ! ( char[0] > 45 && char[0] < 58 )
		ent.signal_emit_stop('insert-text')
	    end
	end

	@dialog.vbox.pack_start( @label,true,true,0  )
	@dialog.vbox.pack_start( @entry,true,true,0  )

	@dialog.add_button(Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL )

	@dialog.add_button(Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK )

	@dialog.set_default_response(Gtk::Dialog::RESPONSE_OK)

	@dialog.signal_connect("response") do |widget, response|
	    case response
	    when Gtk::Dialog::RESPONSE_OK
		@ok=true
		@text = @entry.text
	    end
	end
	@dialog.show_all
	@dialog.run
	@dialog.destroy
    end


    def text
	@text
    end
  
    def to_i
	@text.to_i
    end

    def to_f
	@text.to_f
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
