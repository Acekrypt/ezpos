
module NAS

module Widgets

class BasicWindow < Gtk::Window

    def initialize( name, y_size, x_size )
	super(Gtk::Window::TOPLEVEL)
	set_title( name )
	set_default_size( y_size, x_size )

	alt_s = Gtk::AccelGroup.new
	alt_s.connect( Gdk::Keyval::GDK_S, Gdk::Window::MOD1_MASK, Gtk::ACCEL_VISIBLE) {
	    self.grab_focus
	}
	self.add_accel_group( alt_s )

    end

    def report_error( msg )
	dialog = Gtk::MessageDialog.new(
					    nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::ERROR,Gtk::MessageDialog::BUTTONS_OK,msg
					    )
	dialog.run
	dialog.destroy
    end



end # BasicWindow


end # Widgets

end # NAS
