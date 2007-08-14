require 'nas/widgets/sku_finder'
require 'nas/inv/barcode'


module NAS

module Widgets

class SkuFindDialog

    attr_reader :sku

    def initialize( master, msg )

	@master=master
	@dialog = Gtk::Dialog.new
	@dialog.title = "Barcode Not Found"
	@dialog.transient_for = master
	@dialog.modal=true
	@dialog.set_default_size(300, 300)
	@dialog.vbox.pack_start( Gtk::Label.new(msg),false,true,0  )
	@sku_finder=NAS::Widgets::SkuFinder.new( self )
	@dialog.vbox.pack_start( @sku_finder )
	@dialog.add_button(Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK)
	@dialog.add_button(Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL)
	@dialog.set_default_response(Gtk::Dialog::RESPONSE_CANCEL)

	alt_s = Gtk::AccelGroup.new
	alt_s.connect( Gdk::Keyval::GDK_S, Gdk::Window::MOD1_MASK, Gtk::ACCEL_VISIBLE) {
	    @sku_finder.grab_focus
	}
	@dialog.add_accel_group( alt_s )

	@dialog.signal_connect("response") do |widget, response|
	    case response
	    when Gtk::Dialog::RESPONSE_OK
		@sku=@sku_finder.current_sku
	    else
		@sku=nil
	    end
	end
	@dialog.show_all
    end

    def run
	@dialog.run
    end

    def destroy
	@dialog.destroy
    end

    def got_sku( sku )
	@sku=sku
	@dialog.response( Gtk::Dialog::RESPONSE_OK )
    end

end

end

end
