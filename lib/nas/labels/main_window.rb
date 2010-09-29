require "open3"


module NAS
module Labels

class MainWindow < Gtk::Window

    def update

    end

    def initialize
        super(Gtk::Window::TOPLEVEL)
        set_title( 'Labels' )
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



        main_box=Gtk::VBox.new

        @qty=Gtk::Entry.new
	@qty.text = "1"

	main_box.pack_start( @qty, false, false )


        @sku_finder=NAS::Widgets::SkuFinder.new( self, DEF::POS_SHOW_COST )
	@sku_finder.desc_column.min_width = 800
	def @sku_finder.clear
	        self.focus
	end
        @sku_finder.width_request=450
# ( DEF::POS_WIDTH == 800 ? 350 : 450 )

        main_box.pack_start( @sku_finder,true,true )

        f12 = Gtk::AccelGroup.new
        f12.connect( Gdk::Keyval.const_get( :GDK_F12 ),nil, Gtk::ACCEL_VISIBLE ) {
		puts 'F12'
        }
        self.add_accel_group( f12 )

        main_box.pack_start( @sku_finder, true, true )

        add( main_box )

        self.show_all

    end

	def got_sku(sku)
		lines =	sku.descrip.gsub(/.{1,32}(?:\s|\Z)/){($& + 5.chr).gsub(/\n\005/,"\n").gsub(/\005/,"\n")}
		(one,two) = lines.split("\n")
		one = '' if one.nil?
		two = '' if two.nil?
		price = sprintf('%0.2f',sku.price)
	        lbl=<<-EOP
N
q406
Q203,24
EOP

if 'priced' == ARGV[0]
	lbl += "A#{150 - (price.length/2*11)},0,0,3,2,2,N,\"$#{price}\"\n"
	lbl += "A#{150 - (sku.code.length/2*6)},45,0,4,1,1,N,\"#{sku.code}\"\n"
else
	lbl += "A#{150 - (sku.code.length/2*22)},15,0,4,2,2,N,\"#{sku.code}\"\n"
end
lbl+=<<-EOP
A#{150 - (one.length/2*8)},65,0,2,1,1,N,"#{one}"
A#{150 - (two.length/2*8)},81,0,2,1,1,N,"#{two}"
B#{150 - (sku.code.length/2*15)},108,0,1,2,3,70,N,"#{sku.code}"
P#{@qty.text}
EOP
puts lbl
	        Open3.popen3("lp -s -d #{DEF::RECEIPT_PRINTER}") { | stdin,stdout,stderr |
			stdin.write lbl
		}
		@qty.text="1"
	end

    def enter_deposits
        DailyReceiptsDialog.new( Date.today )
    end

    def shutdown

        Gtk.main_quit
    end



end # MainWindow

end # Labels

end # NAS
