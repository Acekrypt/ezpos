#!/usr/bin/ruby

require 'sku-update'
require 'gtk2'


if fork
    Process.wait 
    exit
end

Process.setsid                 # Become session leader.
exit if fork                   # Zap session leader. See [1].

Dir.chdir "/"                  # Release old working directory.
File.umask 0000                # Ensure sensible umask. Adjust as needed.
STDIN.reopen "/dev/null"                         # Free file descriptors and
STDOUT.reopen "/tmp/ezpos-update.log", "a" # point them somewhere sensible.
STDERR.reopen STDOUT           # STDOUT/ERR should better go to a logfile.


ARGV.push( '--display' )

ARGV.push( ':0' )

Gtk.init
window = Gtk::Window.new

vbox = Gtk::VBox.new(false, 5)


pbar = Gtk::ProgressBar.new

pbar.set_orientation(0)

pbar.set_show_text( true )

vbox.pack_start( Gtk::Label.new( "Now Updating Point of Sale Database..." ) )
vbox.pack_start( pbar, FALSE, FALSE, 5 )

align = Gtk::Alignment.new(0.5, 0.5, 0, 0)

vbox.pack_start(align, false, false, 5);

button = Gtk::Button.new("Cancel")

align.add( button)

button.signal_connect("clicked") { exit }
window.add( vbox )

window.type=Gtk::Window::Type::POPUP
window.window_position=Gtk::Window::POS_CENTER
window.title='Updateing...'
window.set_default_size( 300, 80 )
window.show_all
Gtk.init_add{ 
    num_recs=nil
    cu = UpdateEZPOS.new
    cu.do { | success,msg | 
	if num_recs.nil?
	    if cu.num_records
		num_recs=cu.num_records
	    end
	else
	    pbar.fraction = cu.inc_fraction_done
	end
	# puts msg
	puts msg if ! success
	Gtk.main_iteration_do( false )
    }
}
Gtk.main

