require 'gtk2'

module NAS

module Widgets

class SkuFinder < Gtk::VBox

    attr_accessor :master
    attr_reader :grid

    def show_cost?
        @show_cost
    end

    def initialize( master, show_cost=false )
        super(master)
        @master, @show_cost=master,show_cost

        @nearest=true

        @entry = Gtk::Entry.new
        @entry.signal_connect('key_press_event'){ |widget,key| got_key( widget,key ) }
        @entry.signal_connect('activate'){ |widget| got_activate( widget ) }
        self.pack_start( @entry,false,true,0 )

        @grid=Gtk::TreeView.new
        @grid.signal_connect('cursor_changed'){ |widget| @entry.text = @grid.model.get_value( @grid.selection.selected, 0 ) }
        @grid.signal_connect('row_activated'){ |widget, path, treeview | got_activate( @entry ) }

        win=Gtk::ScrolledWindow.new
        win.hscrollbar_policy=Gtk::POLICY_NEVER
        win.vscrollbar_policy=Gtk::POLICY_AUTOMATIC
        win.add(@grid )

        self.pack_start( win,true,true,0)
        self.set_homogeneous(false)
        column = Gtk::TreeViewColumn.new("Item",Gtk::CellRendererText.new, {:text => 0 })

#        column.min_width = 149
#        column.max_width = 150

        @grid.append_column(column)


        renderer=Gtk::CellRendererText.new
        renderer.ellipsize=Pango::ELLIPSIZE_MIDDLE


        @desc_column = Gtk::TreeViewColumn.new("Description", renderer,{:text => 1} )
        @desc_column.min_width = 299

        @grid.append_column(@desc_column)

        if show_cost?
            renderer=Gtk::CellRendererText.new
            renderer.foreground='grey'
            renderer.xalign=1
            column = Gtk::TreeViewColumn.new('', renderer,{:text => 2} )
            column.min_width = 30
            column.max_width = 40
            @grid.append_column(column)
        end

        @grid_items = Gtk::ListStore.new(String, String,String)
        @grid.model = @grid_items
    end

    def width_request=( width )
        @desc_column.min_width = width-130
        super( width )
    end
    def grab_focus
        @entry.grab_focus
    end

    def use_nearest=( val )
        @nearest=val
    end

    def useing_nearest?
        @nearest
    end

    def got_activate( widget )
        sku=current_sku
        if sku.nil? && ! self.useing_nearest? && ! self.nearest_match.nil?
            dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::ERROR,Gtk::MessageDialog::BUTTONS_CLOSE,"#{widget.text} not found!" )
            dialog.run
            dialog.destroy
        else
            sku = nearest_match if sku.nil?
            @master.got_sku( sku ) if sku
            clear
        end
    end

    def clear
        @grid_items.clear
        @entry.text = ""
        self.focus
    end

    def focus
        @entry.grab_focus
    end

    def current_value
        @entry.text.upcase
    end

    def current_sku
        Sku.find_by_code( current_value )
    end

    def nearest_match
        iter = @grid.model.iter_first
        if iter
            Sku.find( :first, :conditions=> [ 'upper(code) like ?', iter[0].upcase+'%' ] )
        else
            nil
        end
    end

    def got_key( widget, key )
        char = Gdk::Keyval.to_name( key.keyval )
        return if char.nil?
        char.delete!( 'KP_' )
        if 1 == char.size
            char = char[0]
            if char > 47 && char < 123
                @grid_items.clear
#                ActiveRecord::Base.connection.execute("set enable_seqscan to off")
                ActiveRecord::Base.connection.select_all( "select code, descrip, round(cost::numeric/100,2) as cost from skus where upper(code) like #{ActiveRecord::Base.quote( (widget.text + sprintf('%c',char) +'%' ).upcase )} limit 100" ).each do | row |
                    line = @grid_items.append
                    line[0] = row['code']
                    line[1] = row['descrip']
                    line[2] = Money.new( row['cost'] ).format
                end
#                ActiveRecord::Base.connection.execute("set enable_seqscan to default")

            end
        else if 'BackSpace' == char
                 @grid_items.clear
                 if widget.text.size > 1
                     ActiveRecord::Base.connection.select_all( "select code, descrip,round(cost::numeric/100,2) as cost from skus where upper(code) like #{ActiveRecord::Base.quote( widget.text.chop.upcase + '%' )} limit 100" ).each do | row |
                        line = @grid_items.append
                        line[0] = row['code']
                        line[1] = row['descrip']
                        line[2] = Money.new( row['cost'] ).format
                    end
                 end
             end
        end
        false
    end
end


end # module Widget

end # module NAS
