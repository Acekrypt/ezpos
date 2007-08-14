require 'nas/widgets/sku_finder'
require 'nas/inv/barcode'


module NAS

module Widgets

class ScaleWeight

    
    attr_reader :weight


    def get_weight
	Util::Scale.new
    end

    def update
	@weight_label.markup=formatted_weight
    end

    def formatted_weight
	sr = get_weight
	if sr.trust
	    '<span font_desc="Courier Bold 105" background="black" foreground="green">' + sprintf('%.2f',sr.weight) + '</span>'
	else
	    '<span font_desc="Courier Bold 105" background="black" foreground="red">' + sprintf('%.2f',sr.weight) + '</span>'
	end
    end

    def initialize( master )
	
	@master=master
	@dialog = Gtk::Dialog.new
	@dialog.title = "Weighing...."
	@dialog.transient_for = master
	@dialog.modal=true

	@weight_label = Gtk::Label.new
	@weight_label.markup=formatted_weight

	@dialog.vbox.pack_start( @weight_label,true,true,0  )

	@dialog.add_button(Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK)

	@dialog.set_default_response(Gtk::Dialog::RESPONSE_OK)
	@dialog.signal_connect("response") do |widget, response|
	    case response
	    when Gtk::Dialog::RESPONSE_OK
		@weight=get_weight.weight
	    else
		@weight=nil
	    end
	end

	alt_s = Gtk::AccelGroup.new
	alt_s.connect( Gdk::Keyval::GDK_S, Gdk::Window::MOD1_MASK, Gtk::ACCEL_VISIBLE) {
	    @dialog.grab_focus
	}
	@dialog.add_accel_group( alt_s )

	@dialog.show_all
	@idler=Gtk.idle_add{ update }
	@dialog.run
    end


    def destroy
	Gtk.idle_remove(@idler)
	@dialog.destroy
    end

  

end

end

end
